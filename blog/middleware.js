import { NextResponse } from 'next/server';

export function middleware(request) {
  // Intercept all API calls matching /blog-api/*
  if (request.nextUrl.pathname.startsWith('/blog-api')) {
    const requestHeaders = new Headers(request.headers);

    // Inject the shared secret header server-side.
    // This value is securely read from Vercel's environment variables.
    const secret = process.env.VERCEL_PROXY_SECRET || '';
    requestHeaders.set('x-vercel-proxy-secret', secret);

    // Proxy/rewrite the request to the real Fastify backend service
    const destinationUrl = new URL(
      request.nextUrl.pathname + request.nextUrl.search,
      'https://blog-service-topaz.vercel.app'
    );

    return NextResponse.rewrite(destinationUrl, {
      request: {
        headers: requestHeaders,
      },
    });
  }
}

// Target only /blog-api paths
export const config = {
  matcher: '/blog-api/:path*',
};
