export function parseForm(rawBody) {
    try {
      return Object.fromEntries(new URLSearchParams(rawBody));
    } catch (err) {
      console.error("Form parse error:", err);
      return {};
    }
  }
  