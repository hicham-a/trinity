for f in /docker-entrypoint-startup.d/*; do
    echo "$0: running $f"; . "$f"
done
exec "$@"
