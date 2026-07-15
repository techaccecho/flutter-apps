export default async function middleware(request) {
  const url = new URL(request.url);

  // Intercept all API calls matching /blog-api/*
  if (url.pathname.startsWith('/blog-api')) {
    const destination = 'https://blog-service-topaz.vercel.app' + url.pathname + url.search;

    const requestHeaders = new Headers(request.headers);

    // Inject the shared secret header server-side
    const secret = process.env.VERCEL_PROXY_SECRET || '';
    requestHeaders.set('x-vercel-proxy-secret', secret);

    const init = {
      method: request.method,
      headers: requestHeaders,
    };

    // Forward the request body for POST/PUT/PATCH/DELETE mutations
    if (request.method !== 'GET' && request.method !== 'HEAD') {
      init.body = request.body;
      init.duplex = 'half'; // Required for streaming request bodies in Edge Runtime
    }

    // Proxy the request using native Web fetch
    return fetch(destination, init);
  }
}

// Target only /blog-api paths
export const config = {
  matcher: '/blog-api/:path*',
};
