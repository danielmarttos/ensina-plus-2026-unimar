<?php
/**
 * Grava o conteúdo inicial (database/conteudo-inicial.php) no banco.
 * Usado pelo instalador.
 */

function semear_conteudo(array $temas): array
{
    $total = ['temas' => 0, 'modulos' => 0, 'aulas' => 0, 'perguntas' => 0];
    db_transacao(function () use ($temas, &$total) {
        foreach (array_values($temas) as $i => $t) {
            $temaId = db_inserir('temas', [
                'slug' => $t['slug'], 'nome' => $t['nome'], 'subtitulo' => $t['subtitulo'] ?? '',
                'descricao' => $t['descricao'] ?? '', 'icone' => $t['icone'] ?? 'livro',
                'ordem' => $i + 1, 'publicado' => 1, 'criado_em' => agora(),
            ]);
            $total['temas']++;
            foreach (array_values($t['modulos'] ?? []) as $j => $m) {
                $moduloId = db_inserir('modulos', [
                    'tema_id' => $temaId, 'nome' => $m['nome'], 'descricao' => $m['descricao'] ?? '',
                    'ordem' => $j + 1, 'publicado' => 1, 'criado_em' => agora(),
                ]);
                $total['modulos']++;
                foreach (array_values($m['aulas'] ?? []) as $k => $a) {
                    db_inserir('aulas', [
                        'modulo_id' => $moduloId, 'titulo' => $a['titulo'], 'objetivo' => $a['objetivo'] ?? '',
                        'resumo' => $a['resumo'] ?? '', 'passos' => $a['passos'] ?? '', 'url' => $a['url'] ?? null,
                        'arquivo' => null, 'tipo' => $a['tipo'] ?? 'artigo', 'fonte_nome' => $a['fonte_nome'] ?? '',
                        'fonte_url' => $a['fonte_url'] ?? null, 'duracao_min' => $a['duracao_min'] ?? null,
                        'palavras_chave' => $a['palavras_chave'] ?? '', 'busca' => '', 'busca_titulo' => '',
                        'ordem' => $k + 1, 'publicado' => 1, 'criado_em' => agora(),
                    ]);
                    $total['aulas']++;
                }
                foreach (array_values($m['perguntas'] ?? []) as $k => $p) {
                    $perguntaId = db_inserir('perguntas', [
                        'modulo_id' => $moduloId, 'enunciado' => $p['enunciado'], 'tipo' => $p['tipo'],
                        'explicacao' => $p['explicacao'] ?? '', 'ordem' => $k + 1, 'criado_em' => agora(),
                    ]);
                    $alternativas = $p['tipo'] === 'vf'
                        ? [['Verdadeiro', !empty($p['correta'])], ['Falso', empty($p['correta'])]]
                        : $p['alternativas'];
                    foreach (array_values($alternativas) as $n => $alt) {
                        db_inserir('alternativas', [
                            'pergunta_id' => $perguntaId, 'texto' => $alt[0], 'correta' => $alt[1] ? 1 : 0, 'ordem' => $n + 1,
                        ]);
                    }
                    $total['perguntas']++;
                }
            }
        }
    });
    reindexar_aulas();
    return $total;
}
