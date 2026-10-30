/*
 * Ensina+ — JavaScript do site.
 * Tudo aqui é "melhoria": sem JavaScript o site continua funcionando.
 * Escrito em JavaScript simples (sem bibliotecas) para rodar em celulares antigos.
 */
(function () {
  'use strict';

  var doc = document;
  var html = doc.documentElement;
  var base = (doc.body && doc.body.getAttribute('data-base')) || '/';

  function cada(seletor, fn, raiz) {
    Array.prototype.forEach.call((raiz || doc).querySelectorAll(seletor), fn);
  }

  function anunciar(texto) {
    var alvo = doc.getElementById('anuncio');
    if (!alvo) { return; }
    alvo.textContent = '';
    setTimeout(function () { alvo.textContent = texto; }, 60);
  }

  function gravarCookie(nome, valor, dias) {
    var segura = location.protocol === 'https:' ? '; secure' : '';
    doc.cookie = nome + '=' + encodeURIComponent(valor) + '; path=' + base + '; max-age=' + (dias * 86400) + '; samesite=lax' + segura;
  }

  // ---------------------------------------------------------------------
  // Contagem de cliques nos anexos (para os relatórios da equipe)
  // ---------------------------------------------------------------------
  var registrados = {};
  function registrar(aulaId) {
    if (!aulaId || registrados[aulaId]) { return; }
    registrados[aulaId] = true;
    var url = base + 'registrar.php';
    try {
      if (navigator.sendBeacon) {
        var dados = new FormData();
        dados.append('aula', aulaId);
        navigator.sendBeacon(url, dados);
      } else {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.send('aula=' + encodeURIComponent(aulaId));
      }
    } catch (e) { /* não atrapalha a pessoa */ }
  }

  doc.addEventListener('click', function (ev) {
    var link = ev.target.closest ? ev.target.closest('[data-registrar]') : null;
    if (link && link.tagName === 'A' && !link.hasAttribute('data-embed')) {
      registrar(link.getAttribute('data-registrar'));
    }
  });

  // ---------------------------------------------------------------------
  // Vídeo do YouTube "leve": só carrega o player quando a pessoa toca
  // (economiza internet do celular)
  // ---------------------------------------------------------------------
  cada('.video-capa[data-embed]', function (capa) {
    // Sem internet ou sem miniatura: esconde a imagem quebrada (o botão continua)
    var miniatura = capa.querySelector('img');
    if (miniatura) {
      var esconder = function () { miniatura.style.display = 'none'; };
      if (miniatura.complete && miniatura.naturalWidth === 0) { esconder(); }
      miniatura.addEventListener('error', esconder);
    }
    capa.addEventListener('click', function (ev) {
      ev.preventDefault();
      var quadro = doc.createElement('div');
      quadro.className = 'quadro-16x9';
      var iframe = doc.createElement('iframe');
      iframe.src = capa.getAttribute('data-embed') + '&autoplay=1';
      iframe.title = 'Vídeo: ' + (capa.getAttribute('data-titulo') || '');
      iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share');
      iframe.setAttribute('allowfullscreen', '');
      iframe.setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
      quadro.appendChild(iframe);
      capa.parentNode.replaceChild(quadro, capa);
      registrar(capa.getAttribute('data-registrar'));
      iframe.focus();
    });
  });

  // ---------------------------------------------------------------------
  // Áudio: botão grande "Ouvir o áudio" / "Pausar"
  // ---------------------------------------------------------------------
  cada('.audio-tocar', function (botao) {
    var audio = doc.getElementById(botao.getAttribute('data-audio-alvo'));
    if (!audio) { return; }
    var rotulo = botao.querySelector('span');
    botao.hidden = false;
    function atualizar() {
      rotulo.textContent = audio.paused ? 'Ouvir o áudio' : 'Pausar o áudio';
      botao.setAttribute('aria-pressed', audio.paused ? 'false' : 'true');
    }
    botao.addEventListener('click', function () {
      if (audio.paused) { audio.play(); } else { audio.pause(); }
    });
    audio.addEventListener('play', function () { atualizar(); registrar(audio.getAttribute('data-registrar')); });
    audio.addEventListener('pause', atualizar);
    audio.addEventListener('ended', atualizar);
  });
  cada('video[data-registrar]', function (v) {
    v.addEventListener('play', function () { registrar(v.getAttribute('data-registrar')); });
  });

  // ---------------------------------------------------------------------
  // Tamanho da letra e alto contraste (sem recarregar a página)
  // ---------------------------------------------------------------------
  var tamanhos = ['normal', 'grande', 'enorme'];
  function fonteAtual() {
    if (html.classList.contains('fonte-enorme')) { return 'enorme'; }
    if (html.classList.contains('fonte-grande')) { return 'grande'; }
    return 'normal';
  }
  function aplicarFonte(nova) {
    html.classList.remove('fonte-grande', 'fonte-enorme');
    if (nova !== 'normal') { html.classList.add('fonte-' + nova); }
    gravarCookie('em_fonte', nova, 365);
    cada('[data-fonte="normal"]', function (b) { b.setAttribute('aria-pressed', nova === 'normal' ? 'true' : 'false'); });
    anunciar(nova === 'normal' ? 'Letra no tamanho normal' : (nova === 'grande' ? 'Letra grande' : 'Letra bem grande'));
  }
  cada('[data-fonte]', function (botao) {
    botao.addEventListener('click', function (ev) {
      ev.preventDefault();
      var acao = botao.getAttribute('data-fonte');
      var i = tamanhos.indexOf(fonteAtual());
      if (acao === 'maior') { i = Math.min(i + 1, tamanhos.length - 1); }
      else if (acao === 'menor') { i = Math.max(i - 1, 0); }
      else { i = 0; }
      aplicarFonte(tamanhos[i]);
    });
  });
  cada('[data-contraste]', function (botao) {
    botao.addEventListener('click', function (ev) {
      ev.preventDefault();
      var ligado = !html.classList.contains('alto-contraste');
      html.classList.toggle('alto-contraste', ligado);
      gravarCookie('em_contraste', ligado ? '1' : '0', 365);
      cada('[data-contraste]', function (b) { b.setAttribute('aria-pressed', ligado ? 'true' : 'false'); });
      anunciar(ligado ? 'Alto contraste ligado' : 'Alto contraste desligado');
    });
  });

  // ---------------------------------------------------------------------
  // Menus (fecham ao tocar fora ou apertar Esc)
  // ---------------------------------------------------------------------
  doc.addEventListener('click', function (ev) {
    cada('details.menu[open]', function (menu) {
      if (!menu.contains(ev.target)) { menu.removeAttribute('open'); }
    });
  });
  doc.addEventListener('keydown', function (ev) {
    if (ev.key === 'Escape') {
      cada('details.menu[open]', function (menu) {
        menu.removeAttribute('open');
        var s = menu.querySelector('summary');
        if (s) { s.focus(); }
      });
    }
  });

  // ---------------------------------------------------------------------
  // "Mostrar senha"
  // ---------------------------------------------------------------------
  cada('.campo-senha input[type="password"]', function (campo) {
    var botao = doc.createElement('button');
    botao.type = 'button';
    botao.className = 'mostrar-senha';
    botao.textContent = 'Mostrar';
    botao.setAttribute('aria-label', 'Mostrar a senha');
    botao.addEventListener('click', function () {
      var mostrar = campo.type === 'password';
      campo.type = mostrar ? 'text' : 'password';
      botao.textContent = mostrar ? 'Esconder' : 'Mostrar';
      botao.setAttribute('aria-label', mostrar ? 'Esconder a senha' : 'Mostrar a senha');
      campo.focus();
    });
    campo.parentNode.appendChild(botao);
  });

  // ---------------------------------------------------------------------
  // "Ouvir a explicação" (o celular lê o texto em voz alta)
  // ---------------------------------------------------------------------
  var sintese = window.speechSynthesis;
  cada('[data-ouvir]', function (botao) {
    if (!sintese || typeof window.SpeechSynthesisUtterance === 'undefined') { return; }
    botao.hidden = false;
    var rotulo = botao.querySelector('span');
    var textoOriginal = rotulo ? rotulo.textContent : '';
    function parar() {
      sintese.cancel();
      botao.setAttribute('aria-pressed', 'false');
      if (rotulo) { rotulo.textContent = textoOriginal; }
    }
    botao.addEventListener('click', function () {
      if (botao.getAttribute('aria-pressed') === 'true') { parar(); return; }
      var partes = [];
      cada('[data-ler]', function (el) { partes.push(el.innerText || el.textContent); });
      var fala = new window.SpeechSynthesisUtterance(partes.join('. \n'));
      fala.lang = 'pt-BR';
      fala.rate = 0.92;
      var vozes = sintese.getVoices ? sintese.getVoices() : [];
      for (var i = 0; i < vozes.length; i++) {
        if (/pt[-_]BR/i.test(vozes[i].lang)) { fala.voice = vozes[i]; break; }
      }
      fala.onend = parar;
      fala.onerror = parar;
      sintese.cancel();
      sintese.speak(fala);
      botao.setAttribute('aria-pressed', 'true');
      if (rotulo) { rotulo.textContent = 'Parar de ouvir'; }
    });
    window.addEventListener('pagehide', function () { sintese.cancel(); });
  });

  // ---------------------------------------------------------------------
  // Exercício: destaca a opção escolhida (navegadores antigos)
  // ---------------------------------------------------------------------
  cada('.opcoes', function (grupo) {
    grupo.addEventListener('change', function () {
      cada('.opcao', function (op) {
        var input = op.querySelector('input');
        op.classList.toggle('marcada', !!(input && input.checked));
      }, grupo);
    });
  });

  // ---------------------------------------------------------------------
  // Mostrar/esconder campos conforme uma escolha (data-mostrar-se="campo=valor")
  // ---------------------------------------------------------------------
  cada('[data-mostrar-se]', function (bloco) {
    var partes = bloco.getAttribute('data-mostrar-se').split('=');
    var form = bloco.closest('form') || doc;
    function avaliar() {
      var marcado = form.querySelector('[name="' + partes[0] + '"]:checked') || form.querySelector('select[name="' + partes[0] + '"]');
      var valor = marcado ? marcado.value : '';
      bloco.hidden = partes[1].split('|').indexOf(valor) === -1;
    }
    form.addEventListener('change', avaliar);
    avaliar();
  });

  // ---------------------------------------------------------------------
  // Barra de atalhos: marca a página atual e some enquanto a pessoa digita
  // ---------------------------------------------------------------------
  var aqui = location.pathname.replace(/\/$/, '/index.php');
  cada('.nav-app a', function (a) {
    var alvo = a.pathname.replace(/\/$/, '/index.php');
    if (alvo === aqui && !a.hash) { a.setAttribute('aria-current', 'page'); }
  });
  doc.addEventListener('focusin', function (ev) {
    if (/^(INPUT|TEXTAREA|SELECT)$/.test(ev.target.tagName) && ev.target.type !== 'checkbox' && ev.target.type !== 'radio') {
      doc.body.classList.add('digitando');
    }
  });
  doc.addEventListener('focusout', function () { doc.body.classList.remove('digitando'); });

  // ---------------------------------------------------------------------
  // Aplicativo (PWA): funciona offline e pode ser instalado no celular
  // ---------------------------------------------------------------------
  if ('serviceWorker' in navigator && (location.protocol === 'https:' || location.hostname === 'localhost' || location.hostname === '127.0.0.1')) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register(base + 'sw.js', { scope: base }).catch(function () {});
    });
  }

  var pedidoInstalacao = null;
  var instalado = window.matchMedia && window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true;
  function guardadoDispensa() {
    try { return localStorage.getItem('em_instalar_dispensado') === '1'; } catch (e) { return false; }
  }
  window.addEventListener('beforeinstallprompt', function (ev) {
    ev.preventDefault();
    pedidoInstalacao = ev;
    cada('[data-instalar]', function (el) {
      if (el.hasAttribute('data-instalar-banner') && guardadoDispensa()) { return; }
      el.hidden = false;
    });
  });
  cada('[data-instalar-botao]', function (botao) {
    botao.addEventListener('click', function () {
      if (!pedidoInstalacao) { return; }
      pedidoInstalacao.prompt();
      pedidoInstalacao.userChoice.then(function () {
        pedidoInstalacao = null;
        cada('[data-instalar]', function (el) { el.hidden = true; });
      });
    });
  });
  cada('[data-instalar-dispensar]', function (botao) {
    botao.addEventListener('click', function () {
      try { localStorage.setItem('em_instalar_dispensado', '1'); } catch (e) { /* ok */ }
      cada('[data-instalar-banner]', function (el) { el.hidden = true; });
    });
  });
  var ehIOS = /iphone|ipad|ipod/i.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
  if (ehIOS && !instalado) {
    cada('[data-instalar-ios]', function (el) { el.hidden = false; });
  }
  if (instalado) {
    cada('[data-ja-instalado]', function (el) { el.hidden = false; });
  }
})();
