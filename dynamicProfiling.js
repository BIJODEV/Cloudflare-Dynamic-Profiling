import { parseJson } from './parsers/jsonParser.js';
import { parseForm } from './parsers/formParser.js';
import { flattenObject } from './utils/flattenObject.js';
import { detectFormat } from './utils/detectFormat.js';
import { safeExample } from './utils/safeExample.js';
import { hashRequest } from './utils/hashRequest.js';
import { createForwardableRequest } from './utils/createForwardableRequest.js';



export default {
  async fetch(request, env, ctx) {
    return handleRequest(request, env, ctx);
  }
};

const keywordMap = {
  "login issue": ["auth failure", "invalid credentials", "session expired"],
  "timeout": ["latency", "server delay", "response time exceeded"],
  "not loading": ["UI error", "frontend crash", "missing content"],
  "payment failed": ["transaction error", "checkout issue", "billing failed"]
};

function normalizePath(path) {
  return path.replace(/\/[0-9a-fA-F-]{36}(?=\/|$)/g, "/:uuid");
}

function classifyIntent(path, query, body) {
  const text = `${path} ${JSON.stringify(query)} ${JSON.stringify(body)}`.toLowerCase();
  for (const [intent, synonyms] of Object.entries(keywordMap)) {
    if ([intent, ...synonyms].some(k => text.includes(k))) {
      return intent;
    }
  }
  return "unclassified";
}

function getParser(contentType) {
  if (contentType.includes("application/json")) {
    return async (req) => parseJson(await req.text());
  }
  if (contentType.includes("application/x-www-form-urlencoded")) {
    return async (req) => parseForm(await req.text());
  }
  return async () => ({});
}

async function handleRequest(request, env, ctx) {
  const db = env["data-collector"];
  const startTime = Date.now();
  const now = new Date().toISOString();
  const url = new URL(request.url);
  const path = url.pathname;
  const normalizedPath = normalizePath(path);
  const method = request.method;
  const timestamp = new Date().toISOString();

  const ignoredExtensions = [".js", ".css", ".woff", ".woff2", ".ttf", ".ico", ".png", ".jpg", ".jpeg", ".svg", ".map", ".webp"];
  if (ignoredExtensions.some(ext => path.endsWith(ext))) {
    return fetch(request); // Skip profiling
  }

    // Safely consume the request body once
    let bodyText = "";
    const contentType = request.headers.get("content-type") || "";

    if (["POST", "PUT", "PATCH"].includes(method) && !contentType.includes("multipart/form-data")) {
      try {
        bodyText = await request.text(); // Only for non-multipart
      } catch (err) {
        console.error("Failed to read request body:", err);
      }
    }

    // Reconstruct the request for forwarding
    /*const requestClone = new Request(request.url, {
        method: request.method,
        headers: request.headers,
        body: bodyText || (["POST", "PUT", "PATCH"].includes(method) ? request.body : undefined),
    });*/

    const requestToForward = createForwardableRequest(request, bodyText);
    const response = await fetch(requestToForward);
    //const response = await fetch(requestClone);
    const latencyMs = Date.now() - startTime;
    const statusCode = response.status;

  ctx.waitUntil((async () => {
    try {
      const headers = Object.fromEntries(request.headers.entries());
      const authHeader = headers["authorization"] || "";
      const cookieHeader = headers["cookie"] || "";
      const userAgent = headers["user-agent"] || "unknown";
      const ip = headers["cf-connecting-ip"] || "unknown";
      const geo = headers["cf-ipcountry"] || "unknown";

      const isAuthenticated = authHeader.startsWith("Bearer ") || authHeader.includes("Token");
      const cookies = Object.fromEntries(cookieHeader.split(";").map(c => c.trim().split("=")));
      const sessionToken = cookies["session_token"] || cookies["auth"] || null;
      const isLoggedIn = !!sessionToken;
      const authStatus = isAuthenticated || isLoggedIn ? "authenticated" : "unauthenticated";
      const isBot = /bot|crawl|spider/i.test(userAgent);

      const queryParams = Object.fromEntries(url.searchParams.entries());
      const contentType = ["POST", "PUT", "PATCH"].includes(method) ? request.headers.get("content-type") || "" : "";
      const parser = getParser(contentType);
      
      const parserRequest = {
        text: () => Promise.resolve(bodyText),
        formData: () => request.formData?.(), // for multipart
      };

      const bodyData = await parser(parserRequest);
      const flattenedBody = flattenObject(bodyData);
      const intent = classifyIntent(path, queryParams, bodyData);

      const endpointInsert = db.prepare(`
        INSERT INTO endpoints (path, method, last_seen, hit_count, content_type)
        VALUES (?, ?, ?, 1, ?)
        ON CONFLICT(path, method) DO UPDATE SET 
          last_seen = excluded.last_seen,
          hit_count = hit_count + 1,
          content_type = excluded.content_type
      `).bind(normalizedPath, method, timestamp, contentType);

      await endpointInsert.run();

      const endpointQuery = await db.prepare(`
        SELECT id FROM endpoints WHERE path = ? AND method = ?
      `).bind(normalizedPath, method).first();

      const endpoint_id = endpointQuery?.id;
      if (!endpoint_id || isBot) return;

      const statements = [];

      statements.push(db.prepare(`
        INSERT INTO request_context (endpoint_id, timestamp, ip, geo, user_agent, intent, method, auth_status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `).bind(endpoint_id, timestamp, ip, geo, userAgent, intent, method, authStatus));

      for (const [name, value] of Object.entries(queryParams)) {
        statements.push(db.prepare(`
          INSERT INTO parameters (endpoint_id, name, type, min_val, max_val, frequency)
          VALUES (?, ?, ?, ?, ?, 1)
          ON CONFLICT(endpoint_id, name) DO UPDATE SET 
            frequency = frequency + 1,
            min_val = MIN(min_val, ?),
            max_val = MAX(max_val, ?)
        `).bind(endpoint_id, name, typeof value, value, value, value, value));
      }
      
      function processFields(sourceName, fields) {
            for (const [name, value] of Object.entries(flattenedBody)) {
                let safeValue;
                let valueType;

                if (value === null || typeof value === "undefined") {
                safeValue = "null";
                valueType = "null";
                } else if (typeof value === "object") {
                try {
                    safeValue = JSON.stringify(value);
                    valueType = "string";
                } catch {
                    safeValue = "[Unserializable]";
                    valueType = "string";
                }
                } else if (typeof value === "function") {
                safeValue = "[Function]";
                valueType = "string";
                } else {
                safeValue = String(value);
                valueType = typeof value;
                }

                const format = detectFormat(safeValue);
                const example = safeExample(safeValue);

                statements.push(db.prepare(`
                INSERT INTO parameters (endpoint_id, name, type, min_val, max_val, frequency)
                VALUES (?, ?, ?, ?, ?, 1)
                ON CONFLICT(endpoint_id, name) DO UPDATE SET 
                    frequency = frequency + 1,
                    min_val = MIN(min_val, ?),
                    max_val = MAX(max_val, ?)
                `).bind(endpoint_id, name, valueType, safeValue, safeValue, safeValue, safeValue));

                statements.push(db.prepare(`
                INSERT INTO field_metadata (
                    endpoint_id, field_name, data_type, is_required, is_readonly, format,
                    example_value, first_seen, last_seen, seen_count, required_ratio, field_source
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, 1.0, ?)
                ON CONFLICT(endpoint_id, field_name) DO UPDATE SET 
                    example_value = excluded.example_value,
                    format = excluded.format,
                    last_seen = excluded.last_seen,
                    seen_count = field_metadata.seen_count + 1,
                    required_ratio = CAST(field_metadata.seen_count + 1 AS REAL) / CAST((SELECT hit_count FROM endpoints WHERE id = ?) AS REAL),
                    field_source = excluded.field_source
                `).bind(endpoint_id, name, valueType, 1, 0, format, example, now, now, "body", endpoint_id));
            }
        }

      // 🔹 Header Filtering
        const headerFields = {};
        for (const [key, value] of Object.entries(headers)) {
        if (!["authorization", "cookie"].includes(key.toLowerCase())) {
            headerFields[key] = value;
        }
        }

        const cookieFields = Object.fromEntries(
        (headers["cookie"] || "")
            .split(";")
            .map(c => c.trim())
            .filter(c => c.includes("="))
            .map(c => c.split("="))
        );
        
        // 🔹 Cookie Count + Bucket
        const cookieCount = Object.keys(cookieFields).length;
        const cookieCountBucket =
        cookieCount === 0 ? "none" :
        cookieCount <= 5 ? "low" :
        cookieCount <= 15 ? "medium" : "high";

        // 🔹 Request Size Metrics
        const bodySize = bodyText.length;
        const queryCount = Object.keys(queryParams).length;
        const bodyFieldCount = Object.keys(flattenedBody).length;
        const headerCount = Object.keys(headerFields).length;

        // 🔹 Request Hash for Deduplication
        const requestPayload = JSON.stringify({
        endpoint_id,
        queryParams,
        });
        
        const requestHash = await hashRequest(requestPayload);

        // 🔹 Insert Request Metrics
        statements.push(db.prepare(`
        INSERT OR IGNORE INTO request_metrics (
            endpoint_id, timestamp, request_hash, body_size, query_count,
            body_field_count, header_count, cookie_count, cookie_count_bucket
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `).bind(endpoint_id, timestamp, requestHash, bodySize, queryCount, bodyFieldCount, headerCount, cookieCount, cookieCountBucket));

        // 🔹 Process Fields (excluding cookies)
        processFields("query", queryParams);
        processFields("body", flattenedBody);
        processFields("header", headerFields);

      const existing = await db.prepare(`
        SELECT total_hits, avg_latency FROM responses 
        WHERE endpoint_id = ? AND status_code = ?
      `).bind(endpoint_id, statusCode).first();

      if (!existing) {
        statements.push(db.prepare(`
          INSERT INTO responses 
          (endpoint_id, status_code, latency_ms, timestamp, total_hits, avg_latency, last_updated)
          VALUES (?, ?, ?, ?, 1, ?, ?)
        `).bind(endpoint_id, statusCode, latencyMs, now, latencyMs, now));
      } else {
        const newTotal = existing.total_hits + 1;
        const newAvg = (existing.avg_latency * existing.total_hits + latencyMs) / newTotal;

        statements.push(db.prepare(`
          UPDATE responses 
          SET latency_ms = ?, timestamp = ?, total_hits = ?, avg_latency = ?, last_updated = ?
          WHERE endpoint_id = ? AND status_code = ?
        `).bind(latencyMs, now, newTotal, newAvg, now, endpoint_id, statusCode));
      }

      await db.batch(statements);
    } catch (err) {
      console.error("Async logging error:", err);
    }
  })());

  return response;
}

