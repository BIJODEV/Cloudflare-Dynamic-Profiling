/**
 * Safely clones a Request object for forwarding.
 * If bodyOverride is provided, it replaces the original body.
 * Otherwise, the original body is preserved (if not consumed).
 */
export function createForwardableRequest(request, bodyOverride) {
    const init = {
      method: request.method,
      headers: request.headers,
      body: bodyOverride || (["POST", "PUT", "PATCH"].includes(request.method) ? request.body : undefined),
      redirect: request.redirect,
      credentials: request.credentials,
      cache: request.cache,
      mode: request.mode,
      referrer: request.referrer,
      referrerPolicy: request.referrerPolicy,
      integrity: request.integrity,
      keepalive: request.keepalive,
      signal: request.signal,
    };
  
    return new Request(request.url, init);
  }
  