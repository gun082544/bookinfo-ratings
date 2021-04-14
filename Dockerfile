FROM node:14.15.4-alpine3.12

WORKDIR /usr/src/app/

COPY src/ /usr/src/app/
RUN npm install

EXPOSE 8081

CMD ["node", "/usr/src/app/ratings.js", "8081]
