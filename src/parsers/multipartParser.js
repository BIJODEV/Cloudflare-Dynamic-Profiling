export async function parseMultipart(request) {
    try {
      const formData = await request.formData();
      const result = {};
  
      for (const [key, value] of formData.entries()) {
        // If it's a file, you can handle it differently
        if (typeof value === "object" && "name" in value && "type" in value) {
          result[key] = `[File: ${value.name}, Type: ${value.type}]`;
        } else {
          result[key] = value;
        }
      }
  
      return result;
    } catch (err) {
      console.error("Multipart parse error:", err);
      return {};
    }
  }
  