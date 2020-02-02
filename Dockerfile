FROM debian:jessie

LABEL maintainer "h3ct0r <hector@azpurua.me>"

ARG steam_user=anonymous
ARG steam_password=
ARG metamod_version=1.20
ARG amxmod_version=1.8.2

RUN apt-get update && apt-get install -y lib32gcc1 curl vim nano less net-tools lib32stdc++6 unzip

# Install SteamCMD
RUN mkdir -p /opt/steam && cd /opt/steam && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Install HLDS
# Tutorial https://steamcommunity.com/sharedfiles/filedetails/?id=1681186824
RUN mkdir -p /opt/hlds
# Workaround for "app_update 90" bug, see https://forums.alliedmods.net/showthread.php?p=2518786
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit || \ 
    /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 70 validate +quit || :
RUN mkdir -p ~/.steam && ln -s /opt/hlds ~/.steam/sdk32
RUN ln -s /opt/steam/ /opt/hlds/steamcmd
ADD files/steam_appid.txt /opt/hlds/steam_appid.txt
ADD hlds_run.sh /bin/hlds_run.sh

# Add default config
ADD files/server.cfg /opt/hlds/cstrike/server.cfg

# Add maps
ADD maps/* /opt/hlds/cstrike/maps/
ADD files/mapcycle.txt /opt/hlds/cstrike/mapcycle.txt

# Install metamod
RUN mkdir -p /opt/hlds/cstrike/addons/metamod/dlls
RUN curl -sqL "http://prdownloads.sourceforge.net/metamod/metamod-$metamod_version-linux.tar.gz?download" | tar -C /opt/hlds/cstrike/addons/metamod/dlls -zxvf -
ADD files/liblist.gam /opt/hlds/cstrike/liblist.gam
# Remove this line if you aren't going to install/use amxmodx and dproto
ADD files/plugins.ini /opt/hlds/cstrike/addons/metamod/plugins.ini

# Install dproto
RUN mkdir -p /opt/hlds/cstrike/addons/dproto
ADD files/dproto_i386.so /opt/hlds/cstrike/addons/dproto/dproto_i386.so
ADD files/dproto.cfg /opt/hlds/cstrike/dproto.cfg

# Install AMX mod X
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-cstrike-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
ADD files/maps.ini /opt/hlds/cstrike/addons/amxmodx/configs/maps.ini
# Install bullet damage
# https://forums.alliedmods.net/showthread.php?t=88577
ADD files/advanded_bullet_damage.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/advanded_bullet_damage.amxx
RUN echo "advanded_bullet_damage.amxx" >> /opt/hlds/cstrike/addons/amxmodx/configs/plugins.ini

# Install podbot
# https://forums.alliedmods.net/showthread.php?t=220798
# using i386 version
ADD files/podbot_full_V3B22.zip /opt/hlds/cstrike/addons/podbot_full_V3B22.zip
RUN unzip /opt/hlds/cstrike/addons/podbot_full_V3B22.zip -d /opt/hlds/cstrike/addons/ && rm /opt/hlds/cstrike/addons/podbot_full_V3B22.zip

# Cleanup
RUN apt-get remove -y curl

WORKDIR /opt/hlds

ENTRYPOINT ["/bin/hlds_run.sh"]
