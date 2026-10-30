/*
 * Ensina+ — JavaScript do painel (opcional).
 * Mostra, enquanto a pessoa cola o link, que tipo de aula foi reconhecido.
 */
(function () {
  'use strict';

  var campo = document.querySelector('[data-detectar]');
  var caixa = document.querySelector('[data-deteccao]');
  if (!campo || !caixa) { return; }

  function youtubeId(url) {
    var m = url.match(/(?:youtube(?:-nocookie)?\.com\/(?:watch\?(?:.*&)?v=|embed\/|shorts\/|live\/|v\/)|youtu\.be\/)([A-Za-z0-9_-]{11})/);
    return m ? m[1] : null;
  }

  function extensao(url) {
    try {
      var caminho = new URL(url).pathname;
      var m = caminho.match(/\.([a-z0-9]+)$/i);
      return m ? m[1].toLowerCase() : '';
    } catch (e) { return ''; }
  }

  function dominio(url) {
    try { return new URL(url).hostname.replace(/^(www|m)\./, ''); } catch (e) { return ''; }
  }

  function mostrar(html) { caixa.innerHTML = html; }

  function texto(t) {
    var d = document.createElement('div');
    d.textContent = t;
    return d.innerHTML;
  }

  function analisar() {
    var url = campo.value.trim();
    if (!/^https?:\/\//i.test(url)) {
      mostrar(url ? '<p class="adm-detectado adm-detectado-erro">O link precisa começar com https://</p>' : '');
      return;
    }
    var yt = youtubeId(url);
    var ext = extensao(url);
    var host = dominio(url);
    if (yt) {
      mostrar('<div class="adm-detectado"><img src="https://i.ytimg.com/vi/' + yt + '/mqdefault.jpg" alt="" width="160" height="90">' +
        '<p><strong>Vídeo do YouTube</strong><br>Vai tocar dentro do Ensina+, com legendas ligadas quando o vídeo tiver.</p></div>');
    } else if (['mp3', 'm4a', 'ogg', 'oga', 'wav', 'aac', 'opus'].indexOf(ext) !== -1) {
      mostrar('<p class="adm-detectado"><strong>Arquivo de áudio</strong><br>Vai tocar dentro do Ensina+, com um botão grande "Ouvir o áudio". Se tiver a página original, coloque em "Página original".</p>');
    } else if (['mp4', 'webm', 'm4v', 'mov'].indexOf(ext) !== -1) {
      mostrar('<p class="adm-detectado"><strong>Arquivo de vídeo</strong><br>Vai tocar dentro do Ensina+.</p>');
    } else if (ext === 'pdf') {
      mostrar('<p class="adm-detectado"><strong>Cartilha / PDF</strong><br>Abre em outra aba, com o botão "Abrir a cartilha".</p>');
    } else if (/(^|\.)vimeo\.com$/.test(host)) {
      mostrar('<p class="adm-detectado"><strong>Vídeo do Vimeo</strong><br>Vai tocar dentro do Ensina+.</p>');
    } else if (host === 'open.spotify.com') {
      mostrar('<p class="adm-detectado"><strong>Áudio do Spotify</strong><br>O player do Spotify aparece dentro do Ensina+.</p>');
    } else if (host === 'soundcloud.com') {
      mostrar('<p class="adm-detectado"><strong>Áudio do SoundCloud</strong><br>O player aparece dentro do Ensina+.</p>');
    } else {
      mostrar('<p class="adm-detectado"><strong>Artigo ou site</strong> (' + texto(host) + ')<br>Abre em outra aba, no site original, com o botão "Ler o texto".</p>');
    }
  }

  campo.addEventListener('input', analisar);
  analisar();
})();
