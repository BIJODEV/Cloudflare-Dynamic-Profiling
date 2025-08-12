function detectFormat(value) {
    if (typeof value !== "string") return null; 
    if (/^\S+@\S+\.\S+$/.test(value)) return "email";
    if (/^\+?[0-9\s\-]{7,15}$/.test(value)) return "phone";
    if (/^\d{4}-\d{2}-\d{2}/.test(value)) return "date";
    if (/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89ab][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$/.test(value)) return "uuid";
    return null;
  }