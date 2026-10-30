<?php
/**
 * Página inicial: apresentação, "continue de onde parou" e os temas.
 * Não precisa de conta para nada.
 */
require __DIR__ . '/app/bootstrap.php';

$temas = temas_publicados();
$progresso = progresso_por_tema();
$continuar = progresso_continuar();

cabecalho(['classe' => 'pagina-inicio']);
?>
<section class="hero" aria-labelledby="hero-titulo">
  <div class="container hero-grade">
    <div class="hero-texto">
      <h1 id="hero-titulo">Sua jornada para o mundo digital começa aqui!</h1>
      <p class="hero-sub">Aprenda o essencial conosco, a plataforma ASSERTI para inclusão digital. Comece agora!</p>
      <ul class="hero-selos">
        <li><?= icone('check_circulo') ?> Grátis</li>
        <li><?= icone('check_circulo') ?> Sem cadastro</li>
        <li><?= icone('check_circulo') ?> No seu ritmo</li>
      </ul>
      <div class="acoes">
        <a class="botao botao-branco botao-grande" href="#temas"><?= icone('seta_baixo') ?> Escolher um tema</a>
        <a class="hero-link" href="<?= e(url('ajuda.php#como-usar')) ?>">Como funciona?</a>
      </div>
    </div>
  </div>
  <picture class="hero-imagem">
    <source type="image/webp" srcset="<?= e(url('assets/img/hero-480.webp')) ?> 480w, <?= e(url('assets/img/hero.webp')) ?> 780w" sizes="(min-width: 900px) 50vw, 100vw">
    <img src="<?= e(url('assets/img/hero.jpg')) ?>" alt="" width="780" height="567" decoding="async">
  </picture>
</section>

<div class="container">
<?php if ($continuar): ?>
  <section class="continuar" aria-labelledby="continuar-titulo">
<?php if ($continuar['tipo'] === 'aula'): $a = $continuar['aula']; ?>
    <span class="continuar-icone"><?= icone(tipo_info((string) $a['tipo'])['icone']) ?></span>
    <div>
      <p class="continuar-rotulo" id="continuar-titulo"><?= e($continuar['rotulo']) ?></p>
      <p class="continuar-titulo"><?= e($a['titulo']) ?></p>
      <p class="continuar-tema"><?= e($a['tema_nome']) ?></p>
    </div>
    <a class="botao botao-grande" href="<?= e(url('aula.php?id=' . (int) $a['id'])) ?>"><?= icone('play') ?> Continuar</a>
<?php else: $m = $continuar['modulo']; ?>
    <span class="continuar-icone"><?= icone('exercicio') ?></span>
    <div>
      <p class="continuar-rotulo" id="continuar-titulo"><?= e($continuar['rotulo']) ?></p>
      <p class="continuar-titulo">Exercício: <?= e($m['nome']) ?></p>
      <p class="continuar-tema"><?= e($m['tema_nome']) ?> · <?= plural((int) $continuar['num'], 'pergunta', 'perguntas') ?></p>
    </div>
    <a class="botao botao-grande" href="<?= e(url('exercicio.php?modulo=' . (int) $m['id'])) ?>"><?= icone('exercicio') ?> Fazer o exercício</a>
<?php endif; ?>
  </section>
<?php endif; ?>

  <div class="instalar-app" data-instalar data-instalar-banner hidden>
    <?= icone('celular', 'ic-grande') ?>
    <p><strong>Coloque o Ensina+ na tela do seu celular.</strong> Ele abre como um aplicativo, sem ocupar espaço.</p>
    <button type="button" class="botao" data-instalar-botao><?= icone('instalar') ?> Instalar</button>
    <button type="button" class="botao botao-texto" data-instalar-dispensar>Agora não</button>
  </div>
</div>

<section class="secao-temas" id="temas" aria-labelledby="temas-titulo">
  <div class="container">
    <h2 id="temas-titulo" class="titulo-secao">Escolha um tema para começar</h2>
    <p class="subtitulo-secao">Cada tema tem aulas curtas — vídeos, textos e áudios — explicadas passo a passo.</p>
<?php if ($temas): ?>
    <div class="grade-temas">
<?php foreach ($temas as $t): ?>
      <?= cartao_tema($t, $progresso) ?>
<?php endforeach; ?>
    </div>
<?php else: ?>
    <?= aviso('info', 'Ainda não há temas publicados. Volte em breve!') ?>
<?php endif; ?>
  </div>
</section>

<section class="container" aria-labelledby="como-titulo">
  <div class="cartao">
    <h2 id="como-titulo">Como funciona</h2>
    <ol class="passos">
      <li><strong>Escolha um tema</strong> que você quer aprender.</li>
      <li><strong>Abra uma aula:</strong> pode ser um vídeo, um texto ou um áudio, sempre com o passo a passo explicado.</li>
      <li><strong>Marque como concluída</strong> e siga para a próxima. No fim de cada módulo tem um exercício rapidinho.</li>
    </ol>
    <p class="texto-suave">Você não precisa criar conta. Seu progresso fica guardado neste aparelho — e, se quiser, você pode <a href="<?= e(url('criar-conta.php')) ?>">criar uma conta</a> para continuar em qualquer lugar.</p>
  </div>
</section>
<?php
rodape();
