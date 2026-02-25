import { v } from "convex/values";
import { action } from "./_generated/server";

export const fetchOgMetadata = action({
  args: { url: v.string() },
  handler: async (ctx, args) => {
    console.log("Fetching OG metadata for:", args.url);
    
    try {
      // Validate URL
      const url = new URL(args.url);
      
      // Fetch the page
      const response = await fetch(url.toString(), {
        headers: {
          "User-Agent": "Mozilla/5.0 (compatible; GLPTracker/1.0; +https://glptracker.com)",
          "Accept": "text/html,application/xhtml+xml",
          "Accept-Charset": "utf-8",
        },
      });
      
      if (!response.ok) {
        console.log("Failed to fetch URL:", response.status);
        return { error: "Failed to fetch URL", url: args.url };
      }
      
      // Get response as ArrayBuffer and decode as UTF-8
      const buffer = await response.arrayBuffer();
      const decoder = new TextDecoder("utf-8");
      let html = decoder.decode(buffer);
      
      // Decode common HTML entities for Czech characters
      const decodeHtmlEntities = (text: string): string => {
        const entities: Record<string, string> = {
          "&aacute;": "á", "&Aacute;": "Á",
          "&eacute;": "é", "&Eacute;": "É",
          "&iacute;": "í", "&Iacute;": "Í",
          "&oacute;": "ó", "&Oacute;": "Ó",
          "&uacute;": "ú", "&Uacute;": "Ú",
          "&yacute;": "ý", "&Yacute;": "Ý",
          "&ccaron;": "č", "&Ccaron;": "Č",
          "&dcaron;": "ď", "&Dcaron;": "Ď",
          "&ecaron;": "ě", "&Ecaron;": "Ě",
          "&ncaron;": "ň", "&Ncaron;": "Ň",
          "&rcaron;": "ř", "&Rcaron;": "Ř",
          "&scaron;": "š", "&Scaron;": "Š",
          "&tcaron;": "ť", "&Tcaron;": "Ť",
          "&zcaron;": "ž", "&Zcaron;": "Ž",
          "&uring;": "ů", "&Uring;": "Ů",
          "&nbsp;": " ",
          "&amp;": "&",
          "&lt;": "<",
          "&gt;": ">",
          "&quot;": "\"",
          "&apos;": "'",
          "&#39;": "'",
        };
        
        let result = text;
        for (const [entity, char] of Object.entries(entities)) {
          result = result.replace(new RegExp(entity, "gi"), char);
        }
        
        // Handle numeric entities (&#225; etc.)
        result = result.replace(/&#(\d+);/g, (match, num) => 
          String.fromCharCode(parseInt(num, 10))
        );
        // Handle hex entities (&#x00E1; etc.)
        result = result.replace(/&#x([0-9a-f]+);/gi, (match, hex) => 
          String.fromCharCode(parseInt(hex, 16))
        );
        
        return result;
      };
      
      // Parse OG metadata using regex (simple approach without DOM parser)
      const getMetaContent = (property: string): string | null => {
        // Match og: properties
        const ogRegex = new RegExp(
          `<meta[^>]*property=["']${property}["'][^>]*content=["']([^"']*)["']`,
          "i"
        );
        const ogMatch = html.match(ogRegex);
        if (ogMatch) return ogMatch[1];
        
        // Try reverse order (content before property)
        const reverseRegex = new RegExp(
          `<meta[^>]*content=["']([^"']*)["'][^>]*property=["']${property}["']`,
          "i"
        );
        const reverseMatch = html.match(reverseRegex);
        if (reverseMatch) return reverseMatch[1];
        
        return null;
      };
      
      const getMetaName = (name: string): string | null => {
        const nameRegex = new RegExp(
          `<meta[^>]*name=["']${name}["'][^>]*content=["']([^"']*)["']`,
          "i"
        );
        const nameMatch = html.match(nameRegex);
        if (nameMatch) return nameMatch[1];
        
        const reverseRegex = new RegExp(
          `<meta[^>]*content=["']([^"']*)["'][^>]*name=["']${name}["']`,
          "i"
        );
        const reverseMatch = html.match(reverseRegex);
        if (reverseMatch) return reverseMatch[1];
        
        return null;
      };
      
      // Get title - try og:title first, then regular title tag
      let title = getMetaContent("og:title");
      if (!title) {
        const titleMatch = html.match(/<title[^>]*>([^<]*)<\/title>/i);
        title = titleMatch ? titleMatch[1] : null;
      }
      
      // Get description
      let description = getMetaContent("og:description");
      if (!description) {
        description = getMetaName("description");
      }
      
      // Get image
      let image = getMetaContent("og:image");
      // Make image URL absolute if relative
      if (image && !image.startsWith("http")) {
        image = new URL(image, url.origin).toString();
      }
      
      // Get site name
      const siteName = getMetaContent("og:site_name");
      
      // Get favicon
      let favicon: string | null = null;
      const faviconMatch = html.match(/<link[^>]*rel=["'](?:shortcut )?icon["'][^>]*href=["']([^"']*)["']/i);
      if (faviconMatch) {
        favicon = faviconMatch[1];
        if (!favicon.startsWith("http")) {
          favicon = new URL(favicon, url.origin).toString();
        }
      } else {
        // Default favicon location
        favicon = `${url.origin}/favicon.ico`;
      }
      
      // Decode HTML entities in text fields
      const decodedTitle = title ? decodeHtmlEntities(title) : null;
      const decodedDescription = description ? decodeHtmlEntities(description) : null;
      const decodedSiteName = siteName ? decodeHtmlEntities(siteName) : null;
      
      console.log("OG metadata found:", { title: decodedTitle, description: decodedDescription, image: image?.substring(0, 50), siteName: decodedSiteName });
      
      return {
        url: args.url,
        title: decodedTitle || url.hostname,
        description: decodedDescription || null,
        image: image || null,
        siteName: decodedSiteName || url.hostname,
        favicon,
      };
    } catch (error) {
      console.error("Error fetching OG metadata:", error);
      return { error: "Invalid URL or fetch failed", url: args.url };
    }
  },
});
