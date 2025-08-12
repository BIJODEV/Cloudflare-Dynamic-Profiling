function flattenObject(obj, prefix = "") {
    const result = {};
    for (const [key, value] of Object.entries(obj)) {
      const fullKey = prefix ? `${prefix}.${key}` : key;
      if (value !== null && typeof value === "object" && !Array.isArray(value)) {
        Object.assign(result, flattenObject(value, fullKey));
      } else {
        result[fullKey] = value;
      }
    }
    return result;
  }