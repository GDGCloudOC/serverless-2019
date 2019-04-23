# HelloGDG Cloud Run demo
FROM node:10-alpine

WORKDIR /var/local/app

COPY package*.json src ./

RUN npm install --only=production

ENTRYPOINT ["npm"]

CMD ["start"]
