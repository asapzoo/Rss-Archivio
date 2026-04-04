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
          /* ── TITOLO del Html ────────────────────────────────── */
          .site-header h1 {
            font-size: 2rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            color: #63c6f7;
          }

          .site-header h1 .rss-title { color: #fd0; }

          /* ══════════════════════════════════════════════════════
             BYLINE — modifica qui font-size e color a piacimento
             font-size: es. 0.75rem, 1rem, 1.2rem…
             color:     es. #aaaacc, #ffd740, #e94560…
          ══════════════════════════════════════════════════════ */
          .site-header h1 .byline {
            font-size: 0.78rem;
            font-weight: 400;
            color: #9090b8;
            letter-spacing: 0.3px;
            margin-left: 0.5rem;
            vertical-align: middle;
          }

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

          /* ── COLONNA # (numero | dot | stella) in riga ── */
          .col-num {
            width: 90px; text-align: center;
            vertical-align: middle;
            padding: 0.4rem 0.4rem 0.4rem 0.6rem !important;
          }
          .num-wrap {
            display: flex;
            flex-direction: row;
            align-items: center;
            justify-content: center;
            gap: 7px;
          }
          /* ── numero progressivo: giallo, visibile ── */
          .num-text {
            color: #ffd740;
            font-size: 0.92rem;
            font-weight: 700;
            line-height: 1;
            min-width: 20px;
            text-align: right;
          }

          /* Dot progresso — bianco di default, cliccabile per reset */
          .prog-dot {
            display: inline-block;
            width: 14px; height: 14px;
            border-radius: 50%;
            background: #c8c8e0;
            border: 2px solid #c8c8e0;
            cursor: pointer;
            flex-shrink: 0;
            transition: background 0.4s, border-color 0.4s, box-shadow 0.4s;
          }
          .prog-dot.started {
            background: #2060b0;
            border-color: #60b0ff;
            box-shadow: 0 0 6px rgba(96,176,255,0.7);
          }
          .prog-dot.done {
            background: #00a050;
            border-color: #00e676;
            box-shadow: 0 0 7px rgba(0,230,118,0.7);
          }

          /* Stella preferiti */
          .fav-btn {
            background: none; border: none; cursor: pointer;
            font-size: 17px; padding: 0; line-height: 1;
            color: #3a3a5e;
            transition: color 0.2s, transform 0.15s;
          }
          .fav-btn:hover { color: #ffd740; transform: scale(1.3); }
          .fav-btn.faved { color: #ffd740; }

          /* Poco spazio tra colonna # e titolo */
          .col-title { max-width: 300px; padding-left: 0.4rem !important; }

          /* Righe ascoltate / preferite */
          tr.favorited .title-text { color: #e8c840 !important; }
          tr.listened { opacity: 0.65; }
          tr.listened.playing, tr.listened:hover { opacity: 1; }

          /* ── TORNA SU ─────────────────────────────── */
          #backTop {
            position: fixed;
            bottom: 30px; right: 30px;
            width: 40px; height: 40px;
            background: #12121e;
            border: 1.5px solid #e94560;
            color: #e94560;
            border-radius: 50%;
            font-size: 20px;
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            opacity: 0; pointer-events: none;
            transition: opacity 0.3s, transform 0.25s;
            z-index: 150;
            box-shadow: 0 2px 12px rgba(233,69,96,0.3);
          }
          #backTop.vis { opacity: 1; pointer-events: auto; }
          #backTop:hover { transform: translateY(-3px); background: rgba(233,69,96,0.1); }
        </style>
      </head>
      <body>

        <!-- HEADER -->
        <header class="site-header" id="siteHeader">
          <div class="header-inner">

            <div class="header-text">
              <h1>&#127925; <span class="rss-title"><xsl:value-of select="/rss/channel/title"/></span><span class="byline">by The Jackal&#8482; Tnx S@m</span></h1>
              <p class="desc">
                <a href="https://asapzoo.github.io/Rss-Archivio/rss.xml"
                   target="_blank"
                   style="color:#fd0; text-decoration:underline; font-weight:300;">
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
                  <button class="filter-btn" onclick="setFilter('audio/mpeg',this)">&#127911; MP3</button>
                  <button class="filter-btn" onclick="setFilter('video',this)">&#127916; Video</button>
                  <button class="filter-btn" onclick="setFilter('fav',this)">&#9733; Preferiti</button>
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
                <span id="msgText">Lo Zoo non morirà MAI!!!</span>
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
                <th style="width:52px; text-align:center">&#9733;</th>
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
                <xsl:variable name="idx"       select="position()-1"/>
                <!-- id numerico sulla riga; l'URL viene dall'array JS Z_URLS[idx] -->
                <tr id="r{$idx}">
                  <td class="col-num">
                    <div class="num-wrap">
                      <!-- numero progressivo -->
                      <span class="num-text"><xsl:value-of select="position()"/></span>
                      <!-- dot progresso solo per righe non-streaming (pos > 4) -->
                      <xsl:choose>
                        <xsl:when test="position() &gt; 4">
                          <span class="prog-dot" id="dot{$idx}"
                                title="Click per reset"
                                onclick="resetDot({$idx});return false;"> </span>
                        </xsl:when>
                        <xsl:otherwise>
                          <span style="display:inline-block;width:10px;height:10px;"> </span>
                        </xsl:otherwise>
                      </xsl:choose>
                      <!-- stella preferiti -->
                      <button class="fav-btn" title="Preferito"
                              onclick="toggleFav({$idx},this);return false;">&#9733;</button>
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

        <button id="backTop" title="Torna su"
                onclick="window.scrollTo({{top:0,behavior:'smooth'}})">&#8679;</button>

        <footer>The Jackal™ vi augura buon divertimento. Tnx S@m</footer>

        <!-- PLAYER BAR -->
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

        <!-- Array URL generato dall'XSL: indice = id riga (0-based) -->
        <script>
          var Z_URLS = [<xsl:for-each select="/rss/channel/item">'<xsl:value-of select="enclosure/@url"/>'<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>];
        </script>

        <script>
          /* ── STORAGE ───────────────────────────────────────────
             localStorage key "z105"
             entry per URL: p=posizione(s), d=durata(s), f=preferito, done=bool
          ──────────────────────────────────────────────────────── */
          var SK = 'z105';
          var ST = {};
          function loadST() { try { ST = JSON.parse(localStorage.getItem(SK)||'{}'); } catch(e){ST={};} }
          function saveST() { try { localStorage.setItem(SK, JSON.stringify(ST)); } catch(e){} }
          function entry(url) { if (!ST[url]) ST[url]={p:0,d:0,f:false,done:false}; return ST[url]; }

          /* ── Dot aggiornamento ─────────────────────────────── */
          function updateDot(idx) {
            var url = Z_URLS[idx];
            if (!url) return;
            var dot = document.getElementById('dot'+idx);
            if (!dot) return;
            var e = ST[url];
            dot.classList.remove('started','done');
            if (!e) return;
            var pct = e.d > 0 ? e.p / e.d : 0;
            if (e.done || pct >= 0.99)   dot.classList.add('done');
            else if (pct > 0.01)         dot.classList.add('started');
          }

          /* ── Reset dot: azzera posizione e stato ─────────────── */
          function resetDot(idx) {
            var url = Z_URLS[idx];
            if (!url) return;
            if (!confirm('Resettare la cronologia di ascolto per questo episodio?')) return;
            if (ST[url]) { ST[url].p = 0; ST[url].d = 0; ST[url].done = false; }
            saveST();
            updateDot(idx);
            var row = document.getElementById('r'+idx);
            if (row) row.classList.remove('listened');
          }

          function updateAllDots() {
            for (var i = 0; i &lt; Z_URLS.length; i++) { updateDot(i); }
          }

          /* ── Applica classi fav/listened alle righe ─────────── */
          function applyRowStates() {
            for (var i = 0; i &lt; Z_URLS.length; i++) {
              var url = Z_URLS[i];
              var row = document.getElementById('r'+i);
              if (!row || !url) continue;
              var e = ST[url];
              var faved    = e &amp;&amp; e.f;
              var listened = e &amp;&amp; (e.done || (e.d > 0 &amp;&amp; e.p/e.d >= 0.99));
              row.classList.toggle('favorited', !!faved);
              row.classList.toggle('listened',  !!listened);
              var star = row.querySelector('.fav-btn');
              if (star) star.classList.toggle('faved', !!faved);
            }
          }

          /* ── Toggle preferito ──────────────────────────────── */
          function toggleFav(idx, btn) {
            var url = Z_URLS[idx];
            if (!url) return;
            var e = entry(url);
            e.f = !e.f;
            saveST();
            btn.classList.toggle('faved', e.f);
            var row = document.getElementById('r'+idx);
            if (row) row.classList.toggle('favorited', e.f);
            if (currentFilter === 'fav') filterTable();
          }

          /* ── PLAYER ────────────────────────────────────────── */
          var currentFilter = 'all';
          var saveTimer     = null;
          var currentIdx    = -1;

          function getRows() { return document.querySelectorAll('#mainTable tbody tr'); }

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
              var ms   = !q || text.indexOf(q) !== -1;
              var mf;
              if (currentFilter === 'all')          mf = true;
              else if (currentFilter === 'fav')     mf = row.classList.contains('favorited');
              else if (currentFilter === 'video')   mf = mt === 'video';
              else                                  mf = mt === currentFilter;
              if (ms &amp;&amp; mf) { row.classList.remove('hidden'); visible++; }
              else             { row.classList.add('hidden'); }
            });
            document.getElementById('countBadge').textContent = visible + ' episodi';
          }

          function setFilter(type, btn) {
            currentFilter = type;
            document.querySelectorAll('.filter-btn').forEach(function(b){b.classList.remove('active');});
            btn.classList.add('active');
            filterTable();
          }

          /* Salva posizione ogni 5s */
          function persistPos(el, idx) {
            var url = Z_URLS[idx];
            if (!url || !el || !el.duration) return;
            var e = entry(url);
            e.p = el.currentTime;
            e.d = el.duration;
            if (e.d > 0 &amp;&amp; e.p/e.d >= 0.99) e.done = true;
            saveST();
            updateDot(idx);
            var row = document.getElementById('r'+idx);
            if (row) row.classList.toggle('listened', !!e.done);
          }

          function hookMedia(el, idx) {
            el.addEventListener('timeupdate', function() { persistPos(el, idx); });
            el.addEventListener('ended', function() {
              var url = Z_URLS[idx];
              if (url) { var e = entry(url); e.done = true; saveST(); updateDot(idx); }
            });
          }

          function playMedia(url, type, title, rowEl) {
            var audioEl = document.getElementById('audio-player');
            var videoEl = document.getElementById('video-player');
            var liveEl  = document.getElementById('live-iframe');
            var bar     = document.getElementById('player-bar');
            document.getElementById('player-title').textContent = title || url;
            document.querySelectorAll('tr.playing').forEach(function(r){r.classList.remove('playing');});
            if (rowEl) rowEl.classList.add('playing');
            liveEl.src = ''; liveEl.style.display = 'none';
            clearInterval(saveTimer);

            /* trova indice dall'URL */
            var idx = -1;
            for (var i = 0; i &lt; Z_URLS.length; i++) { if (Z_URLS[i] === url) { idx = i; break; } }
            currentIdx = idx;
            var savedPos = (idx >= 0 &amp;&amp; ST[url] &amp;&amp; ST[url].p > 5) ? ST[url].p : 0;

            if (type === 'video') {
              audioEl.pause(); audioEl.style.display = 'none';
              videoEl.src = url; videoEl.style.display = 'block';
              videoEl.addEventListener('loadedmetadata', function(){ if(savedPos>0)videoEl.currentTime=savedPos; videoEl.play(); },{once:true});
              if (idx >= 0) hookMedia(videoEl, idx);
              document.body.classList.remove('player-open','player-open-live');
              document.body.classList.add('player-open-video');
            } else {
              videoEl.pause(); videoEl.style.display = 'none';
              audioEl.src = url; audioEl.style.display = 'block';
              audioEl.addEventListener('loadedmetadata', function(){ if(savedPos>0)audioEl.currentTime=savedPos; audioEl.play(); },{once:true});
              if (idx >= 0) hookMedia(audioEl, idx);
              document.body.classList.remove('player-open-video','player-open-live');
              document.body.classList.add('player-open');
            }
            saveTimer = setInterval(function(){ persistPos(type==='video'?videoEl:audioEl, currentIdx); }, 5000);
            bar.classList.add('visible');
          }

          function playLive(url, title, rowEl) {
            var audioEl = document.getElementById('audio-player');
            var videoEl = document.getElementById('video-player');
            var liveEl  = document.getElementById('live-iframe');
            document.querySelectorAll('tr.playing').forEach(function(r){r.classList.remove('playing');});
            if (rowEl) rowEl.classList.add('playing');
            document.getElementById('player-title').textContent = title || 'Diretta Live';
            clearInterval(saveTimer);
            audioEl.pause(); audioEl.style.display = 'none';
            videoEl.pause(); videoEl.style.display = 'none';
            liveEl.src = url; liveEl.style.display = 'block';
            document.body.classList.remove('player-open','player-open-video');
            document.body.classList.add('player-open-live');
            document.getElementById('player-bar').classList.add('visible');
          }

          function closePlayer() {
            var audioEl = document.getElementById('audio-player');
            var videoEl = document.getElementById('video-player');
            var liveEl  = document.getElementById('live-iframe');
            if (currentIdx >= 0) persistPos(audioEl.style.display!=='none'?audioEl:videoEl, currentIdx);
            clearInterval(saveTimer);
            audioEl.pause(); audioEl.src = '';
            videoEl.pause(); videoEl.src = '';
            liveEl.src = ''; liveEl.style.display = 'none';
            document.getElementById('player-bar').classList.remove('visible');
            document.body.classList.remove('player-open','player-open-video','player-open-live');
            document.querySelectorAll('tr.playing').forEach(function(r){r.classList.remove('playing');});
            currentIdx = -1;
          }

          /* ── INIT ──────────────────────────────────────────── */
          window.onload = function() {
            loadST();
            filterTable();
            applyRowStates();
            updateAllDots();

            var hdr     = document.getElementById('siteHeader');
            var backTop = document.getElementById('backTop');

            function setBodyPad() { document.body.style.paddingTop = hdr.offsetHeight + 'px'; }
            setBodyPad();
            window.addEventListener('resize', setBodyPad);

            var lastY = 0, ticking = false;
            window.addEventListener('scroll', function() {
              if (!ticking) {
                window.requestAnimationFrame(function() {
                  var y = window.scrollY;
                  if (y > lastY &amp;&amp; y > hdr.offsetHeight) hdr.classList.add('hdr-hidden');
                  else hdr.classList.remove('hdr-hidden');
                  if (y > 400) backTop.classList.add('vis');
                  else backTop.classList.remove('vis');
                  lastY = y; ticking = false;
                });
                ticking = true;
              }
            });

            var msgEl = document.getElementById('msgText');
            var barEl = document.getElementById('msgBar');
            if (msgEl &amp;&amp; barEl &amp;&amp; !msgEl.textContent.trim()) barEl.classList.add('msg-empty');
          };
        </script>

      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
