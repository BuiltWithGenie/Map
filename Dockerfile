FROM julia:latest
RUN apt-get update && apt-get install -y wget tar clang
RUN useradd --create-home --shell /bin/bash genie
RUN mkdir /home/genie/app
COPY . /home/genie/app/
WORKDIR /home/genie/app
RUN chown -R genie:genie /home/
USER genie
RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.develop(url=\"./GenieAI/\");"
EXPOSE 8000
EXPOSE 80
ENV JULIA_DEPOT_PATH "/home/genie/.julia"
ENV JULIA_REVISE = "off"
ENV GENIE_ENV "prod"
ENV GENIE_HOST "0.0.0.0"
ENV PORT "8000"
ENV WSPORT "8000"
ENV EARLYBIND "true"
ENTRYPOINT ["julia", "--sysimage=/sysimg/map.so", "--project", "-e", "using GenieFramework; Genie.loadapp(); up(async=false);"]


# FROM julia:latest
# RUN apt-get update && apt-get install -y wget tar
# RUN useradd --create-home --shell /bin/bash genie
# RUN mkdir /home/genie/app
# COPY . /home/genie/app/
# WORKDIR /home/genie/app
# RUN chown -R genie:genie /home/
# USER genie
# ENV GITHUB_TOKEN "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"
# ENV OPENAI_API_KEY "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"
# RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.develop(url=\"./GenieAI/\");Pkg.instantiate(); Pkg.precompile();"
# EXPOSE 8000
# EXPOSE 80
# ENV JULIA_DEPOT_PATH "/home/genie/.julia"
# ENV JULIA_REVISE = "off"
# ENV GENIE_ENV "prod"
# ENV GENIE_HOST "0.0.0.0"
# ENV PORT "8000"
# ENV WSPORT "8000"
# ENV EARLYBIND "true"
# ENTRYPOINT ["julia", "--project", "-e", "using GenieFramework; Genie.loadapp(); up(async=false);"]
#
#
