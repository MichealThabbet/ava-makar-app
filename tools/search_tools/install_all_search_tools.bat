@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
REM ================================================================
REM  Install ALL search / scraping / heritage tools  (Ava-Makar)
REM  Run:  double-click, or from CMD:  install_all_search_tools.bat
REM  Needs: Python 3.10+ , Node.js , Git , Docker Desktop (running)
REM  Everything is logged to install_log.txt next to this file.
REM ================================================================
cd /d "%~dp0"
set "LOG=%~dp0install_log.txt"
set "FAILED="
echo ==== start %date% %time% ==== > "%LOG%"

echo.
echo [0] Checking tools...
where python >nul 2>&1 || (echo   ** Python not found - install from python.org then run again & set "NOPY=1")
where node   >nul 2>&1 || (echo   ** Node.js not found - npm part will be skipped & set "NONODE=1")
where git    >nul 2>&1 || (echo   ** Git not found - git part will be skipped & set "NOGIT=1")
docker info  >nul 2>&1 || (echo   ** Docker not running - start Docker Desktop; docker part will be skipped & set "NODOCKER=1")

REM ---------------- 1) Python packages (in separate env: search_env) ----------------
if defined NOPY goto :npm
echo.
echo [1] Python packages  (separate environment: search_env)
if not exist "search_env\Scripts\python.exe" python -m venv search_env >>"%LOG%" 2>&1
set "PY=%~dp0search_env\Scripts\python.exe"
"%PY%" -m pip install --upgrade pip wheel setuptools >>"%LOG%" 2>&1

REM -- search engines / metasearch / APIs
for %%P in (ddgs serpapi tavily-python exa-py firecrawl-py apify-client) do call :pip %%P
REM -- browsers that pass protection
for %%P in (playwright patchright camoufox[geoip] seleniumbase selenium undetected-chromedriver nodriver zendriver DrissionPage botasaurus playwright-stealth) do call :pip %%P
REM -- fast HTTP with browser fingerprint
for %%P in (curl_cffi cloudscraper tls-client hrequests requests beautifulsoup4 lxml) do call :pip %%P
REM -- crawling / extraction
for %%P in (scrapy crawl4ai crawlee[all] scrapling[all] trafilatura) do call :pip %%P
REM -- deep research agents
for %%P in (gpt-researcher knowledge-storm) do call :pip %%P
REM -- web archives / big indexes
for %%P in (waybackpy cdx_toolkit internetarchive) do call :pip %%P
REM -- libraries / academic / heritage
for %%P in (pyeuropeana SPARQLWrapper pyalex habanero semanticscholar) do call :pip %%P
REM -- Tor control / captcha clients
for %%P in (stem 2captcha-python capsolver anticaptchaofficial) do call :pip %%P

echo   - downloading browsers for the tools (takes time)...
"%PY%" -m playwright install chromium firefox >>"%LOG%" 2>&1 || set "FAILED=!FAILED! playwright-browsers"
"%~dp0search_env\Scripts\patchright.exe" install chromium >>"%LOG%" 2>&1 || set "FAILED=!FAILED! patchright-browser"
"%~dp0search_env\Scripts\camoufox.exe" fetch >>"%LOG%" 2>&1 || set "FAILED=!FAILED! camoufox-browser"
"%~dp0search_env\Scripts\scrapling.exe" install >>"%LOG%" 2>&1 || set "FAILED=!FAILED! scrapling-browsers"
"%~dp0search_env\Scripts\crawl4ai-setup.exe" >>"%LOG%" 2>&1 || set "FAILED=!FAILED! crawl4ai-setup"

:npm
REM ---------------- 2) Node.js packages ----------------
if defined NONODE goto :docker
echo.
echo [2] Node.js packages
for %%N in (puppeteer puppeteer-extra puppeteer-extra-plugin-stealth crawlee) do (
  echo   - npm %%N
  call npm install -g %%N >>"%LOG%" 2>&1 || set "FAILED=!FAILED! npm:%%N"
)
echo   - rebrowser-patches: run inside a puppeteer/playwright project with:  npx rebrowser-patches@latest patch

:docker
REM ---------------- 3) Docker services (run on your PC) ----------------
if defined NODOCKER goto :git
echo.
echo [3] Docker services
call :dock searxng      8888:8080 searxng/searxng
call :dock whoogle      5000:5000 benbusby/whoogle-search
call :dock yacy         8090:8090 yacy/yacy_search_server
call :dock librey       8081:8080 ghcr.io/ahwxorg/librey
call :dock flaresolverr 8191:8191 ghcr.io/flaresolverr/flaresolverr:latest
call :dock byparr       8192:8191 ghcr.io/thephaseless/byparr:latest
echo   - pull browsertrix-crawler (runs on demand, not as a service)
docker pull webrecorder/browsertrix-crawler >>"%LOG%" 2>&1 || set "FAILED=!FAILED! docker:browsertrix"

:git
REM ---------------- 4) Git projects ----------------
if defined NOGIT goto :winget
echo.
echo [4] Git projects
if not exist "open_deep_research" (git clone --depth 1 https://github.com/langchain-ai/open_deep_research.git >>"%LOG%" 2>&1 || set "FAILED=!FAILED! git:open_deep_research")
if not exist "firecrawl" (git clone --depth 1 https://github.com/firecrawl/firecrawl.git >>"%LOG%" 2>&1 || set "FAILED=!FAILED! git:firecrawl")
if defined NODOCKER goto :winget
if exist "firecrawl\docker-compose.yaml" (
  echo   - starting Firecrawl (first time builds images, can take long^)
  if not exist "firecrawl\.env" (echo USE_DB_AUTHENTICATION=false> "firecrawl\.env")
  pushd firecrawl
  docker compose up -d >>"%LOG%" 2>&1 || set "FAILED=!FAILED! firecrawl-compose"
  popd
)

:winget
REM ---------------- 5) Windows programs ----------------
where winget >nul 2>&1 || goto :done
echo.
echo [5] Windows programs (winget)
for %%W in (TorProject.TorBrowser JernejSimoncic.Wget XavierRoche.HTTrack) do (
  echo   - %%W
  winget install -e --id %%W --accept-source-agreements --accept-package-agreements >>"%LOG%" 2>&1 || set "FAILED=!FAILED! winget:%%W"
)

:done
echo.
echo ================================================================
echo  DONE.  Log: %LOG%
if defined FAILED (echo  FAILED: !FAILED!) else (echo  All steps finished without errors.)
echo.
echo  Use the Python tools:   search_env\Scripts\activate
echo  Local services:
echo     SearXNG       http://localhost:8888
echo     Whoogle       http://localhost:5000
echo     YaCy          http://localhost:8090
echo     LibreY        http://localhost:8081
echo     FlareSolverr  http://localhost:8191
echo     Byparr        http://localhost:8192
echo     Firecrawl API http://localhost:3002
echo.
echo  Need an account/API key (nothing to install):
echo     Google Programmable Search, Brave Search API, Serper, SearchAPI.io, Zenserp,
echo     DataForSEO, Bright Data, Oxylabs, Tavily, Exa, Perplexity Sonar, Jina AI,
echo     You.com, Kagi, Mojeek, Marginalia, SerpAPI, Apify, WorldCat (OCLC),
echo     2Captcha / CapSolver / Anti-Captcha, residential proxies (Decodo, IPRoyal)
echo  Websites / free APIs (used from scripts, nothing to install):
echo     Europeana, Internet Archive, Wikidata, HathiTrust, Gallica SRU, Library of Congress,
echo     DPLA, Google Books, Open Library, BASE, CORE, OpenAlex, Crossref, Semantic Scholar,
echo     Lens.org, Unpaywall, Common Crawl, Wayback CDX, Memento TimeTravel, archive.today,
echo     Arquivo.pt, UK Web Archive, Biblissima+, Pinakes, Diktyon, Trismegistos, papyri.info,
echo     PAThs, Coptic SCRIPTORIUM, CMCL, SDBM, Digital Scriptorium, Manuscriptorium,
echo     Handschriftenportal, Qalamos, Beta mashaheft, Syriaca.org, LDAB, e-codices,
echo     e-manuscripta, Qatar Digital Library, Manuscripta Mediaevalia
echo ================================================================
pause
exit /b

REM ---------------- helpers ----------------
:pip
echo   - pip %~1
"%PY%" -m pip install --upgrade "%~1" >>"%LOG%" 2>&1 || set "FAILED=!FAILED! pip:%~1"
exit /b

:dock
echo   - %~1  (port %~2)
docker rm -f %~1 >nul 2>&1
docker run -d --name %~1 -p %~2 --restart unless-stopped %~3 >>"%LOG%" 2>&1 || set "FAILED=!FAILED! docker:%~1"
exit /b
