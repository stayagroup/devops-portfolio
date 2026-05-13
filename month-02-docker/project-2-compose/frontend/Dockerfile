FROM nginx:alpine

# Copy frontend files FIRST
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD sh -c "test -f /usr/share/nginx/html/index.html || exit 1"

CMD ["nginx", "-g", "daemon off;"]
