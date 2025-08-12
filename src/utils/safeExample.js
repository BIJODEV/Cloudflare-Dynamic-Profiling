function safeExample(value) {
    const str = String(value);
    return str.length > 200 ? str.slice(0, 197) + "..." : str;
  }