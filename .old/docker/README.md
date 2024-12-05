# Directus Docker
to make the data folders usable, get the id of the directus container:
```
docker ps
```
And then set the permissions:
```
docker exec -u root <id-of-the-directus-container> chown -R node:node /directus/database /directus/extensions /directus/uploads
```
