FROM ubuntu

RUN apt-get update
RUN apt-get -y install expect redis-server nodejs npm

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN npm install -g coffee-script
RUN npm install -g yo generator-hubot

# Create hubot user
RUN	useradd -d /hubot -m -s /bin/bash -U hubot

# Log in as hubot user and change directory
USER	hubot
WORKDIR /hubot

# Install hubot
RUN yo hubot --owner="zojoncj@oregonstate.edu" --name="Bubba" --description="Testing hubot in Docker" --defaults

RUN npm install hubot-slack --save && npm install
RUN npm install hubot-auth --save && npm install
RUN npm install hubot-reload-scripts --save && npm install

ADD hubot/external-scripts.json /hubot/

ADD hubot/scripts/ztest.coffee /hubot/scripts/

CMD ["bin/hubot", "--adapter", "slack"]


