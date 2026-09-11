FROM node:22-bookworm AS build
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@11.7.0 --activate
COPY . .
RUN rm -f .git/config.worktree
RUN pnpm install --frozen-lockfile
RUN pnpm run build

FROM node:22-bookworm-slim AS runtime
ENV NODE_ENV=production DSH_HOME=/data
WORKDIR /app
RUN apt-get update \
  && apt-get install -y --no-install-recommends bash git ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && corepack enable \
  && corepack prepare pnpm@11.7.0 --activate
COPY --from=build /app /app
RUN mkdir -p /data /workspace
EXPOSE 3080
VOLUME ["/data", "/workspace"]
ENTRYPOINT ["node", "/app/apps/cli/lib/bin.js"]
CMD ["--profile", "web", "--no-open", "--host", "0.0.0.0", "--port", "3080"]
