<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:atom="http://www.w3.org/2005/Atom">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>


  <!-- Template: converti data RSS in formato italiano -->
  <xsl:template name="formatDateIT">
    <xsl:param name="dateStr"/>
    <!-- es: "Tue, 17 Mar 2026 16:00:00 +0100" -->
    <xsl:variable name="dayAbbr"  select="substring-before($dateStr, ',')"/>
    <xsl:variable name="rest"     select="substring-after($dateStr, ', ')"/>
    <xsl:variable name="dayNum"   select="substring-before($rest, ' ')"/>
    <xsl:variable name="rest2"    select="substring-after($rest, ' ')"/>
    <xsl:variable name="monthAbbr" select="substring-before($rest2, ' ')"/>
    <xsl:variable name="rest3"    select="substring-after($rest2, ' ')"/>
    <xsl:variable name="year"     select="substring-before($rest3, ' ')"/>

    <!-- Giorno della settimana -->
    <xsl:choose>
      <xsl:when test="$dayAbbr='Mon'">Lunedì </xsl:when>
      <xsl:when test="$dayAbbr='Tue'">Martedì </xsl:when>
      <xsl:when test="$dayAbbr='Wed'">Mercoledì </xsl:when>
      <xsl:when test="$dayAbbr='Thu'">Giovedì </xsl:when>
      <xsl:when test="$dayAbbr='Fri'">Venerdì </xsl:when>
      <xsl:when test="$dayAbbr='Sat'">Sabato </xsl:when>
      <xsl:when test="$dayAbbr='Sun'">Domenica </xsl:when>
    </xsl:choose>

    <xsl:value-of select="$dayNum"/>
    <xsl:text> </xsl:text>

    <!-- Mese -->
    <xsl:choose>
      <xsl:when test="$monthAbbr='Jan'">Gennaio</xsl:when>
      <xsl:when test="$monthAbbr='Feb'">Febbraio</xsl:when>
      <xsl:when test="$monthAbbr='Mar'">Marzo</xsl:when>
      <xsl:when test="$monthAbbr='Apr'">Aprile</xsl:when>
      <xsl:when test="$monthAbbr='May'">Maggio</xsl:when>
      <xsl:when test="$monthAbbr='Jun'">Giugno</xsl:when>
      <xsl:when test="$monthAbbr='Jul'">Luglio</xsl:when>
      <xsl:when test="$monthAbbr='Aug'">Agosto</xsl:when>
      <xsl:when test="$monthAbbr='Sep'">Settembre</xsl:when>
      <xsl:when test="$monthAbbr='Oct'">Ottobre</xsl:when>
      <xsl:when test="$monthAbbr='Nov'">Novembre</xsl:when>
      <xsl:when test="$monthAbbr='Dec'">Dicembre</xsl:when>
    </xsl:choose>

    <xsl:text> </xsl:text>
    <xsl:value-of select="$year"/>
  </xsl:template>

  <xsl:template match="/">
    <html lang="it">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title><xsl:value-of select="/rss/channel/title"/> — Archivio</title>
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }

          body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background: #0f0f14;
            color: #e2e2e8;
            min-height: 100vh;
          }

          /* ── HEADER — fixed, scompare scrollando giù ── */
          .site-header {
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            padding: 1rem 2rem 0.9rem;
            border-bottom: 2px solid #e94560;
            position: fixed;
            top: 0; left: 0; right: 0;
            z-index: 100;
            box-shadow: 0 4px 20px rgba(0,0,0,0.5);
            transition: transform 0.32s cubic-bezier(0.4,0,0.2,1);
          }
          .site-header.hdr-hidden { transform: translateY(-100%); }

          .header-inner {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1.2rem;
          }

          .header-text { flex: 1; min-width: 0; }

          /* ── Colonna destra: [msg | immagine] in riga ── */
          .header-img-wrap {
            flex-shrink: 0;
            display: flex;
            flex-direction: row;
            align-items: center;
            gap: 0.75rem;
          }

          .header-img-wrap a { display: block; line-height: 0; }

          .header-img {
            height: clamp(80px, 8.5vw, 120px);
            width: auto;
            border-radius: 10px;
            object-fit: cover;
            box-shadow: 0 4px 18px rgba(0,0,0,0.55);
            transition: opacity 0.2s, transform 0.2s;
          }
          .header-img:hover { opacity: 0.82; transform: scale(1.03); }

          /* ── MESSAGGIO DEL GIORNO ──────────────────────
             Per modificare: cerca id="msgText" nel file HTML
             e cambia solo il testo tra i tag span.
             Per nasconderlo: svuota il testo (scompare da solo).
          ─────────────────────────────────────────────── */
          .msg-bar {
            display: flex;
            align-items: flex-start;
            gap: 0.35rem;
            background: rgba(233,69,96,0.10);
            border: 1px solid rgba(233,69,96,0.28);
            border-radius: 7px;
            padding: 0.4rem 0.7rem;
            font-size: 0.73rem;
            color: #ffb3be;
            line-height: 1.4;
            max-width: 180px;
          }
          .msg-bar-icon { flex-shrink: 0; font-size: 0.82rem; margin-top: 1px; }
          .msg-bar.msg-empty { display: none; }

          .site-header h1 {
            font-size: 2rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            color: #ffffff;
          }

          .site-header h1 span { color: #fd0; }

          .site-header p.desc {
            color: #fd0;
            font-size: 0.85rem;
            margin-top: 0.25rem;
          }

          /* ── TOOLBAR ────────────────────────────────── */
          .toolbar {
            max-width: 1400px;
            margin: 1.5rem auto 0;
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            align-items: center;
          }

          .search-box {
            flex: 1;
            min-width: 200px;
            background: #1e1e2e;
            border: 1px solid #333355;
            border-radius: 8px;
            padding: 0.6rem 1rem;
            color: #e2e2e8;
            font-size: 0.9rem;
            outline: none;
            transition: border-color 0.2s;
          }
          .search-box:focus { border-color: #e94560; }
          .search-box::placeholder { color: #666680; }

          .filter-btns { display: flex; gap: 0.5rem; flex-wrap: wrap; }

          .filter-btn {
            background: #1e1e2e;
            border: 1px solid #333355;
            border-radius: 6px;
            padding: 0.5rem 0.9rem;
            color: #a0a0b8;
            cursor: pointer;
            font-size: 0.8rem;
            font-weight: 600;
            transition: all 0.2s;
          }
          .filter-btn:hover, .filter-btn.active {
            background: #e94560;
            border-color: #e94560;
            color: #fff;
          }

          .count-badge {
            background: #e94560;
            color: #fff;
            border-radius: 20px;
            padding: 0.2rem 0.6rem;
            font-size: 0.75rem;
            font-weight: 700;
            margin-left: auto;
          }

          /* ── TABLE WRAPPER ──────────────────────────── */
          .table-wrapper {
            max-width: 1400px;
            margin: 1.5rem auto 3rem;
            padding: 0 1rem;
          }

          table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            background: #16161e;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(0,0,0,0.4);
          }

          thead th {
            background: #1a1a2e;
            color: #c0c0d8;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            padding: 0.9rem 1rem;
            border-bottom: 2px solid #333355;
            text-align: left;
            white-space: nowrap;
          }

          tbody tr {
            border-bottom: 1px solid #1e1e2e;
            transition: background 0.15s;
          }
          tbody tr:last-child { border-bottom: none; }
          tbody tr:nth-child(even) { background: #18181f; }
          tbody tr:hover { background: #1f1f30 !important; }
          tbody tr.hidden { display: none; }

          td {
            padding: 0.8rem 1rem;
            vertical-align: middle;
            font-size: 0.88rem;
          }

          .col-title { max-width: 320px; }

          .title-text {
            font-weight: 600;
            color: #d8d8f0;
            line-height: 1.35;
          }

          /* ── BADGE ──────────────────────────────────── */
          .badge {
            display: inline-block;
            font-size: 0.65rem;
            font-weight: 700;
            padding: 0.15rem 0.45rem;
            border-radius: 4px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 0.35rem;
          }
          .badge-mp3   { background: #163b2b; color: #4ecca3; border: 1px solid #2a6b4f; }

          .badge-video { background: #1b2b3b; color: #60a5fa; border: 1px solid #2b5b8b; }

          .badge-stream {
            background: #2a0a10; color: #ff4466; border: 1px solid #e94560;
            animation: streamPulse 2s infinite;
          }
          @keyframes streamPulse { 0%,100%{opacity:1} 50%{opacity:0.6} }

          .col-date { white-space: nowrap; color: #8888aa; font-size: 0.82rem; }
          .col-desc { color: #8888aa; font-size: 0.82rem; max-width: 260px; }
          .col-play { text-align: center; }

          .play-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            background: linear-gradient(135deg, #e94560, #c23152);
            color: #fff;
            text-decoration: none;
            border-radius: 7px;
            padding: 0.45rem 0.85rem;
            font-size: 0.8rem;
            font-weight: 600;
            white-space: nowrap;
            transition: transform 0.15s, box-shadow 0.15s;
            box-shadow: 0 2px 8px rgba(233,69,96,0.3);
            cursor: pointer;
            border: none;
          }
          .play-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 14px rgba(233,69,96,0.5);
          }
          .play-btn svg { width: 12px; height: 12px; fill: currentColor; }

          .play-btn-video {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
            box-shadow: 0 2px 8px rgba(59,130,246,0.3);
          }
          .play-btn-video:hover {
            box-shadow: 0 4px 14px rgba(59,130,246,0.5);
          }

          .play-btn-live {
            background: linear-gradient(135deg, #e94560, #7c1030);
            box-shadow: 0 2px 8px rgba(233,69,96,0.45);
          }
          .play-btn-live:hover { box-shadow: 0 4px 14px rgba(233,69,96,0.65); }

          body.player-open-live { padding-bottom: 420px; }

          #live-iframe {
            width: 100%;
            height: 340px;
            border: none;
            border-radius: 10px;
            background: #000;
          }

          footer {
            text-align: center;
            color: #444466;
            font-size: 0.75rem;
            padding: 1.5rem;
          }

          /* ── PLAYER BAR — fisso, centrato in basso ─── */
          #player-bar {
            display: none;
            position: fixed;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 90%;
            max-width: 860px;
            background: linear-gradient(135deg, #1a1a2e, #0f3460);
            border: 2px solid #e94560;
            border-bottom: none;
            border-radius: 14px 14px 0 0;
            box-shadow: 0 -6px 32px rgba(0,0,0,0.7);
            z-index: 200;
            padding: 0.9rem 1.4rem;
            flex-direction: column;
            align-items: center;
            gap: 0.6rem;
          }
          #player-bar.visible { display: flex; }

          /* riga superiore: titolo + chiudi */
          .player-top {
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.8rem;
          }

          #player-title {
            flex: 1;
            font-size: 0.85rem;
            font-weight: 600;
            color: #fd0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
          }

          #player-close {
            background: #e94560;
            border: none;
            color: #fff;
            border-radius: 50%;
            width: 28px; height: 28px;
            font-size: 0.95rem;
            cursor: pointer;
            flex-shrink: 0;
            transition: background 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
          }
          #player-close:hover { background: #c23152; }

          /* riga inferiore: controlli centrati */
          .player-controls {
            width: 100%;
            display: flex;
            justify-content: center;
          }

          #audio-player {
            width: 100%;
            max-width: 700px;
            height: 40px;
            border-radius: 8px;
            outline: none;
            accent-color: #e94560;
          }

          #video-player {
            width: 100%;
            max-width: 480px;
            max-height: 200px;
            border-radius: 10px;
            border: 1px solid #333355;
          }

          /* evidenzia riga in riproduzione */
          tr.playing { background: #1a1a30 !important; }
          tr.playing .title-text { color: #fd0 !important; }

          body.player-open       { padding-bottom: 110px; }
          body.player-open-video { padding-bottom: 290px; }

          /* ── COLONNA # con dot + stella ────────────── */
          .col-num {
            text-align: center;
            vertical-align: middle;
            padding: 0.5rem 0.6rem !important;
            width: 54px;
          }
          .num-wrap {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 3px;
          }
          .num-text { color: #444466; font-size: 0.78rem; line-height: 1; }

          /* Progress dot SVG */
          .prog-dot { display: block; width: 16px; height: 16px; flex-shrink: 0; }
          .prog-dot .trk { fill: none; stroke: #2a2a3e; stroke-width: 2.5; }
          .prog-dot .fil {
            fill: none; stroke: #2a2a3e; stroke-width: 2.5;
            stroke-linecap: round;
            transform: rotate(-90deg); transform-origin: 50% 50%;
            transition: stroke-dashoffset 1.2s linear, stroke 0.4s;
          }
          .prog-dot.started .fil { stroke: #60b0ff; }
          .prog-dot.done    .fil { stroke: #00e676; }

          /* Fav star button */
          .fav-btn {
            background: none; border: none; cursor: pointer;
            font-size: 13px; padding: 0; line-height: 1; color: #2a2a3e;
            transition: color 0.2s, transform 0.15s;
          }
          .fav-btn:hover { color: #ffd740; transform: scale(1.25); }
          .fav-btn.faved { color: #ffd740; }

          /* Righe stato */
          tr.favorited .title-text { color: #e8c840 !important; }
          tr.listened  { opacity: 0.72; }
          tr.listened.playing,
          tr.listened:hover { opacity: 1; }

          /* ── TORNA SU ─────────────────────────────── */
          #backTop {
            position: fixed;
            bottom: 28px; right: 28px;
            width: 42px; height: 42px;
            background: #12121e;
            border: 1.5px solid #e94560;
            color: #e94560;
            border-radius: 50%;
            font-size: 18px;
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            opacity: 0; pointer-events: none;
            transition: opacity 0.3s, transform 0.25s;
            z-index: 150;
            box-shadow: 0 2px 14px rgba(233,69,96,0.35);
          }
          #backTop.visible { opacity: 1; pointer-events: auto; }
          #backTop:hover { transform: translateY(-3px); background: rgba(233,69,96,0.12); }
        </style>
      </head>
      <body>

        <!-- HEADER -->
        <header class="site-header" id="siteHeader">
          <div class="header-inner">

            <div class="header-text">
              <h1>&#127925; <span><xsl:value-of select="/rss/channel/title"/></span> <span/></h1>
              <p class="desc">
                <a href="https://asapzoo.github.io/Rss-Archivio/rss.xml"
                   target="_blank"
                   style="color:#fd0; text-decoration:underline; font-weight:600;">
                  Novit&#224; da ora anche dai Browser
                </a>
                <a href="https://feeds.feedburner.com/zoo105"
                   target="_blank"
                   style="color:#fd0; text-decoration:none; font-weight:600; margin-left:0.75rem; border:1px solid #fd0; border-radius:5px; padding:0.1rem 0.5rem; font-size:0.78rem; vertical-align:middle;">
                  &#127911; App Podcast
                </a>
              </p>
              <div class="toolbar">
                <input class="search-box" type="text" id="searchInput"
                       placeholder="&#128269; Cerca per titolo o descrizione&#8230;"
                       oninput="filterTable()"/>
                <div class="filter-btns">
                  <button class="filter-btn active" onclick="setFilter('all',this)">Tutti</button>
                  <button class="filter-btn" onclick="setFilter('audio/mpeg',this)">&#127925; MP3</button>
                  <button class="filter-btn" onclick="setFilter('video',this)">&#127916; Video</button>
                  <button class="filter-btn" onclick="setFilter('fav',this)">&#11088; Preferiti</button>
                </div>
                <span class="count-badge" id="countBadge">&#160;</span>
              </div>
            </div>

            <!-- Colonna destra: [📣 messaggio] [immagine] in riga -->
            <div class="header-img-wrap">

              <!-- ═══════════════════════════════════════════
                   MESSAGGIO DEL GIORNO
                   Modifica il testo nello span qui sotto.
                   Svuotalo per nascondere la barra.
                   ═══════════════════════════════════════════ -->
              <div class="msg-bar" id="msgBar">
                <span class="msg-bar-icon">&#128227;</span>
                <span id="msgText">Scrivi qui il messaggio del giorno</span>
              </div>

              <a href="https://telegra.ph/COME-ASCOLTARE-I-PODCAST-DELLO-ZOO-DI-105-SU-ANDROID-E-iOS-01-12"
                 target="_blank" title="Come ascoltare i podcast dello Zoo di 105">
                <img class="header-img"
                     src="https://d1yei2z3i6k35z.cloudfront.net/7771559/68cd3024a516b_Copilot_20250919_112135.jpg"
                     alt="Zoo 105"/>
              </a>

            </div>

          </div>
        </header>

        <!-- TABLE -->
        <div class="table-wrapper">
          <table id="mainTable">
            <thead>
              <tr>
                <th style="width:54px; text-align:center">&#9733;</th>
                <th style="width:28%">Titolo</th>
                <th style="width:22%">Descrizione</th>
                <th style="width:16%">Data pubblicazione</th>
                <th style="width:12%; text-align:center">Ascolta / Guarda</th>
              </tr>
            </thead>
            <tbody>
              <xsl:for-each select="/rss/channel/item">
                <xsl:variable name="mediaType" select="enclosure/@type"/>
                <xsl:variable name="isVideo"   select="contains($mediaType,'video')"/>
                <xsl:variable name="isStream"  select="contains($mediaType,'dash')"/>
                <xsl:variable name="mediaUrl"  select="enclosure/@url"/>
                <tr data-url="{$mediaUrl}">
                  <!-- Colonna #: stella + dot progresso + numero -->
                  <td class="col-num">
                    <div class="num-wrap">
                      <!-- stella preferiti -->
                      <button class="fav-btn" title="Aggiungi ai preferiti"
                              onclick="toggleFav(this.closest('tr').dataset.url, this); return false;">
                        &#9733;
                      </button>
                      <!-- dot progresso (solo per audio/video, non live) -->
                      <xsl:choose>
                        <xsl:when test="not($isStream)">
                          <svg class="prog-dot" viewBox="0 0 16 16"
                               data-url="{$mediaUrl}">
                            <circle class="trk" cx="8" cy="8" r="6"/>
                            <circle class="fil" cx="8" cy="8" r="6"
                                    stroke-dasharray="37.7"
                                    stroke-dashoffset="37.7"/>
                          </svg>
                        </xsl:when>
                        <xsl:otherwise>
                          <span style="display:inline-block;width:16px;height:16px;"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <!-- numero progressivo -->
                      <span class="num-text">
                        <xsl:value-of select="position()"/>
                      </span>
                    </div>
                  </td>
                  <td class="col-title">
                    <xsl:choose>
                      <xsl:when test="$isStream">
                        <span class="badge badge-stream">&#128250; LIVE</span><br/>
                      </xsl:when>
                      <xsl:when test="$isVideo">
                        <span class="badge badge-video">Video</span><br/>
                      </xsl:when>
                      <xsl:otherwise>
                        <span class="badge badge-mp3">MP3</span><br/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <span class="title-text"><xsl:value-of select="title"/></span>
                  </td>
                  <td class="col-desc">
                    <xsl:choose>
                      <xsl:when test="$isStream">
                        <a href="https://asapzoo.github.io/Rss-Archivio/player-multi.html"
                           target="_blank"
                           style="color:#e94560; font-weight:600;">
                          &#9654; Apri il player
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="description"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>
                  <td class="col-date">
                    <xsl:call-template name="formatDateIT">
                      <xsl:with-param name="dateStr" select="pubDate"/>
                    </xsl:call-template>
                  </td>
                  <td class="col-play">
                    <xsl:choose>
                      <xsl:when test="$isStream">
                        <a class="play-btn play-btn-live" href="#"
                           onclick="playLive('https://asapzoo.github.io/Rss-Archivio/player-multi.html',this.closest('tr').querySelector('.title-text').textContent,this.closest('tr'));return false;">
                          <svg viewBox="0 0 24 24"><path d="M21 3L3 10.53v.98l6.84 2.65L12.48 21h.98L21 3z"/></svg>
                          Guarda
                        </a>
                      </xsl:when>
                      <xsl:when test="$isVideo">
                        <a class="play-btn play-btn-video" href="#"
                           onclick="playMedia('{$mediaUrl}','video',this.closest('tr').querySelector('.title-text').textContent,this.closest('tr'));return false;">
                          <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                          Guarda
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                        <a class="play-btn" href="#"
                           onclick="playMedia('{$mediaUrl}','audio',this.closest('tr').querySelector('.title-text').textContent,this.closest('tr'));return false;">
                          <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                          Ascolta
                        </a>
                      </xsl:otherwise>
                    </xsl:choose>
                  </td>
                </tr>
              </xsl:for-each>
            </tbody>
          </table>
        </div>

        <button id="backTop" title="Torna su" onclick="window.scrollTo({top:0,behavior:'smooth'})">
          &#8679;
        </button>

        <footer>The Jackal vi augura buon divertimento. Tnk S@m</footer>

        <!-- PLAYER BAR — centrato in basso -->
        <div id="player-bar">
          <div class="player-top">
            <span id="player-title">—</span>
            <button id="player-close" onclick="closePlayer()" title="Chiudi">&#10005;</button>
          </div>
          <div class="player-controls">
            <audio id="audio-player" controls="controls" preload="none" style="display:none"></audio>
            <video id="video-player" controls="controls" preload="none" style="display:none"></video>
            <iframe id="live-iframe" allowfullscreen="allowfullscreen"
                    allow="autoplay; fullscreen" style="display:none"> </iframe>
          </div>
        </div>

        <script>
          /* ═══════════════════════════════════════════════════════
             STORAGE  (localStorage key: z105)
             Struttura: { "url": { p, d, f, done } }
               p    = posizione (secondi)
               d    = durata    (secondi)
               f    = preferito (bool)
               done = ascoltato >85% (bool)
             ═══════════════════════════════════════════════════════ */
          var STORE_KEY = 'z105';
          var store = {};

          function loadStore() {
            try { store = JSON.parse(localStorage.getItem(STORE_KEY) || '{}'); }
            catch(e) { store = {}; }
          }

          function saveStore() {
            try { localStorage.setItem(STORE_KEY, JSON.stringify(store)); }
            catch(e) {}
          }

          function getEntry(url) {
            if (!store[url]) store[url] = { p: 0, d: 0, f: false, done: false };
            return store[url];
          }

          /* ── Aggiorna dot SVG per un URL ──────────────────────── */
          function updateDot(url) {
            var e = store[url];
            if (!e) return;
            var dot = document.querySelector('.prog-dot[data-url="' + url + '"]');
            if (!dot) return;
            var fil = dot.querySelector('.fil');
            if (!fil) return;
            var circ = 37.7; // 2π×6
            var pct  = (e.d > 0) ? Math.min(e.p / e.d, 1) : 0;
            fil.setAttribute('stroke-dashoffset', (circ * (1 - pct)).toFixed(2));
            dot.classList.remove('started', 'done');
            if (e.done || pct >= 0.85)     { dot.classList.add('done'); }
            else if (pct > 0.01)            { dot.classList.add('started'); }
          }

          function updateAllDots() {
            Object.keys(store).forEach(function(url) { updateDot(url); });
          }

          /* ── Riapplica classi fav/listened alle righe ─────────── */
          function applyRowStates() {
            getRows().forEach(function(row) {
              var url = row.dataset.url;
              if (!url) return;
              var e = store[url];
              if (!e) return;
              row.classList.toggle('favorited', !!e.f);
              row.classList.toggle('listened',  !!(e.done || (e.d > 0 &amp;&amp; e.p / e.d >= 0.85)));
              var star = row.querySelector('.fav-btn');
              if (star) star.classList.toggle('faved', !!e.f);
            });
          }

          /* ── Toggle preferito ─────────────────────────────────── */
          function toggleFav(url, btn) {
            if (!url) return;
            var e = getEntry(url);
            e.f = !e.f;
            saveStore();
            btn.classList.toggle('faved', e.f);
            var row = btn.closest('tr');
            if (row) row.classList.toggle('favorited', e.f);
            // se filtro preferiti attivo, aggiorna visibilità
            if (currentFilter === 'fav') filterTable();
          }

          /* ═══════════════════════════════════════════════════════
             PLAYER
             ═══════════════════════════════════════════════════════ */
          var currentFilter = 'all';
          var saveTimer = null;
          var currentUrl = null;

          function getRows() {
            return document.querySelectorAll('#mainTable tbody tr');
          }

          function rowMediaType(row) {
            var badge = row.querySelector('.badge');
            if (!badge) return '';
            var t = badge.textContent.trim().toLowerCase();
            if (t.indexOf('live') !== -1) return 'stream';
            if (t === 'video') return 'video';
            return 'audio/mpeg';
          }

          function filterTable() {
            var q = document.getElementById('searchInput').value.toLowerCase();
            var rows = getRows();
            var visible = 0;
            rows.forEach(function(row) {
              var text = row.textContent.toLowerCase();
              var mt   = rowMediaType(row);
              var matchSearch = !q || text.indexOf(q) !== -1;
              var matchFilter;
              if (currentFilter === 'all') {
                matchFilter = true;
              } else if (currentFilter === 'fav') {
                var url = row.dataset.url;
                matchFilter = url &amp;&amp; store[url] &amp;&amp; !!store[url].f;
              } else if (currentFilter === 'video') {
                matchFilter = mt === 'video';
              } else {
                matchFilter = mt === currentFilter;
              }
              if (matchSearch &amp;&amp; matchFilter) {
                row.classList.remove('hidden'); visible++;
              } else {
                row.classList.add('hidden');
              }
            });
            document.getElementById('countBadge').textContent = visible + ' episodi';
          }

          function setFilter(type, btn) {
            currentFilter = type;
            document.querySelectorAll('.filter-btn').forEach(function(b) {
              b.classList.remove('active');
            });
            btn.classList.add('active');
            filterTable();
          }

          /* ── Salva posizione ogni 5s e al pause ───────────────── */
          function startSaving(mediaEl, url) {
            clearInterval(saveTimer);
            saveTimer = setInterval(function() { persistPos(mediaEl, url); }, 5000);
            mediaEl.addEventListener('pause',  function() { persistPos(mediaEl, url); }, { once: false });
            mediaEl.addEventListener('ended',  function() { markDone(url); }, { once: false });
          }

          function persistPos(mediaEl, url) {
            if (!url || !mediaEl.duration) return;
            var e = getEntry(url);
            e.p = mediaEl.currentTime;
            e.d = mediaEl.duration;
            if (e.p / e.d >= 0.85) { e.done = true; }
            saveStore();
            updateDot(url);
            // aggiorna stato riga
            var row = document.querySelector('tr[data-url="' + url + '"]');
            if (row) row.classList.toggle('listened', !!(e.done));
          }

          function markDone(url) {
            var e = getEntry(url);
            e.done = true;
            saveStore();
            updateDot(url);
            var row = document.querySelector('tr[data-url="' + url + '"]');
            if (row) row.classList.add('listened');
          }

          /* ── timeupdate → aggiorna dot in tempo reale ─────────── */
          function hookTimeUpdate(mediaEl, url) {
            mediaEl.addEventListener('timeupdate', function() {
              if (!mediaEl.duration) return;
              var e = getEntry(url);
              e.p = mediaEl.currentTime;
              e.d = mediaEl.duration;
              updateDot(url);
            });
          }

          function playMedia(url, type, title, rowEl) {
            var audioEl  = document.getElementById('audio-player');
            var videoEl  = document.getElementById('video-player');
            var liveEl   = document.getElementById('live-iframe');
            var bar      = document.getElementById('player-bar');
            var titleEl  = document.getElementById('player-title');

            document.querySelectorAll('tr.playing').forEach(function(r) { r.classList.remove('playing'); });
            if (rowEl) rowEl.classList.add('playing');
            titleEl.textContent = title || url;
            liveEl.src = ''; liveEl.style.display = 'none';
            clearInterval(saveTimer);
            currentUrl = url;

            var savedPos = (store[url] &amp;&amp; store[url].p > 5) ? store[url].p : 0;

            if (type === 'video') {
              audioEl.pause(); audioEl.style.display = 'none';
              videoEl.src = url; videoEl.style.display = 'block';
              videoEl.addEventListener('loadedmetadata', function() {
                if (savedPos > 0) { videoEl.currentTime = savedPos; }
                videoEl.play();
              }, { once: true });
              hookTimeUpdate(videoEl, url);
              startSaving(videoEl, url);
              document.body.classList.remove('player-open', 'player-open-live');
              document.body.classList.add('player-open-video');
            } else {
              videoEl.pause(); videoEl.style.display = 'none';
              audioEl.src = url; audioEl.style.display = 'block';
              audioEl.addEventListener('loadedmetadata', function() {
                if (savedPos > 0) { audioEl.currentTime = savedPos; }
                audioEl.play();
              }, { once: true });
              hookTimeUpdate(audioEl, url);
              startSaving(audioEl, url);
              document.body.classList.remove('player-open-video', 'player-open-live');
              document.body.classList.add('player-open');
            }
            bar.classList.add('visible');
          }

          function playLive(url, title, rowEl) {
            var audioEl = document.getElementById('audio-player');
            var videoEl = document.getElementById('video-player');
            var liveEl  = document.getElementById('live-iframe');
            var bar     = document.getElementById('player-bar');
            var titleEl = document.getElementById('player-title');

            document.querySelectorAll('tr.playing').forEach(function(r) { r.classList.remove('playing'); });
            if (rowEl) rowEl.classList.add('playing');
            titleEl.textContent = '&#128250; ' + (title || 'Diretta Live');
            clearInterval(saveTimer);
            audioEl.pause(); audioEl.style.display = 'none';
            videoEl.pause(); videoEl.style.display = 'none';
            liveEl.src = url; liveEl.style.display = 'block';
            document.body.classList.remove('player-open', 'player-open-video');
            document.body.classList.add('player-open-live');
            bar.classList.add('visible');
          }

          function closePlayer() {
            var audioEl = document.getElementById('audio-player');
            var videoEl = document.getElementById('video-player');
            var liveEl  = document.getElementById('live-iframe');
            if (currentUrl) persistPos(audioEl.style.display !== 'none' ? audioEl : videoEl, currentUrl);
            clearInterval(saveTimer);
            audioEl.pause(); audioEl.src = '';
            videoEl.pause(); videoEl.src = '';
            liveEl.src = ''; liveEl.style.display = 'none';
            document.getElementById('player-bar').classList.remove('visible');
            document.body.classList.remove('player-open', 'player-open-video', 'player-open-live');
            document.querySelectorAll('tr.playing').forEach(function(r) { r.classList.remove('playing'); });
            currentUrl = null;
          }

          /* ═══════════════════════════════════════════════════════
             INIT
             ═══════════════════════════════════════════════════════ */
          window.onload = function() {
            loadStore();
            filterTable();
            applyRowStates();
            updateAllDots();

            var hdr = document.getElementById('siteHeader');

            function setBodyPad() {
              document.body.style.paddingTop = hdr.offsetHeight + 'px';
            }
            setBodyPad();
            window.addEventListener('resize', setBodyPad);

            // Nascondi header scrollando giù
            var lastY = 0;
            var ticking = false;
            var backTop = document.getElementById('backTop');

            window.addEventListener('scroll', function() {
              if (!ticking) {
                window.requestAnimationFrame(function() {
                  var y = window.scrollY;
                  // header hide/show
                  if (y > lastY &amp;&amp; y > hdr.offsetHeight) {
                    hdr.classList.add('hdr-hidden');
                  } else {
                    hdr.classList.remove('hdr-hidden');
                  }
                  lastY = y;
                  // back-to-top
                  if (y > 400) { backTop.classList.add('visible'); }
                  else         { backTop.classList.remove('visible'); }
                  ticking = false;
                });
                ticking = true;
              }
            }, { passive: true });

            // Nascondi msg-bar se testo vuoto
            var msgEl = document.getElementById('msgText');
            var barEl = document.getElementById('msgBar');
            if (msgEl &amp;&amp; barEl &amp;&amp; !msgEl.textContent.trim()) {
              barEl.classList.add('msg-empty');
            }
          };
        </script>

      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
