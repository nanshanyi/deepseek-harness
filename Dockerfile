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
RUN groupadd --system dsh && useradd --system --gid dsh --home-dir /data dsh
COPY --from=build --chown=dsh:dsh /app /app
RUN mkdir -p /data /workspace && chown -R dsh:dsh /data /workspace
USER dsh
EXPOSE 3080
VOLUME ["/data", "/workspace"]
ENTRYPOINT ["/app/node_modules/.bin/dsh"]
CMD ["--profile", "web", "--no-open", "--host", "0.0.0.0", "--port", "3080"]
