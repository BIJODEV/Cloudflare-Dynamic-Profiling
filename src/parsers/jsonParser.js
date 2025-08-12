export function parseJson(rawBody) {
    try {
      return JSON.parse(rawBody);
    } catch (err) {
      console.error("JSON parse error:", err);
      return {};
    }
  }  