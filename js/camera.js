/* ============================================================
   EYE GATE v2 — Câmera com MODO FORÇADO
   ★ Solta qualquer stream antigo do próprio app antes de abrir
   ★ 1ª tentativa normal → depois tenta CADA câmera conectada
     (uma por uma, 2x cada) → por último modo sem restrição
   ★ Traduz TODO erro pra português claro com o que fazer
   ★ Painel de erro GRANDE com botão TENTAR DE NOVO
   ============================================================ */

const Camera = {

  _meusStreams: new Set(),

  async listarCameras() {
    try {
      const devs = await navigator.mediaDevices.enumerateDevices();
      return devs.filter(d => d.kind === "videoinput");
    } catch (e) { return []; }
  },

  /* solta todos os streams que este app já abriu (trava clássica) */
  soltarTudo() {
    for (const s of this._meusStreams) {
      try { s.getTracks().forEach(t => t.stop()); } catch (e) {}
    }
    this._meusStreams.clear();
  },

  _sleep(ms) { return new Promise(r => setTimeout(r, ms)); },

  /* abre a câmera FORÇANDO: tenta várias estratégias até uma funcionar.
     Se falhar, o erro ganha .cameraInfo {titulo, msg} em pt-BR. */
  async abrir(preferencias = {}) {
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      throw Object.assign(new Error("sem-mediadevices"), {
        cameraInfo: {
          titulo: "Ambiente não permite câmera",
          msg: "Este modo de abrir o app bloqueia a câmera. Use o EYE GATE instalado no Windows (atalho da área de trabalho) — lá a câmera funciona."
        }
      });
    }

    /* ★ 0. solta o que ficou pendurado de antes */
    this.soltarTudo();

    const abrir = async (video) => {
      const s = await navigator.mediaDevices.getUserMedia({ video, audio: false });
      this._meusStreams.add(s);
      return s;
    };

    /* ★ 1. tentativa normal, como foi pedido */
    let ultimoErro = null;
    try {
      return await abrir(preferencias);
    } catch (e) {
      ultimoErro = e;
      // permissão negada ou sem câmera: não adianta insistir
      if (["NotAllowedError", "PermissionDeniedError", "NotFoundError", "DevicesNotFoundError"].includes(e?.name)) {
        throw Object.assign(e, { cameraInfo: this._traduzir(e) });
      }
    }

    /* ★ 2. MODO FORÇADO: cada câmera conectada, uma por uma, 2 tentativas */
    const cams = await this.listarCameras();
    for (const dev of cams) {
      for (let tent = 0; tent < 2; tent++) {
        try {
          return await abrir({ deviceId: { exact: dev.deviceId } });
        } catch (e) {
          ultimoErro = e;
          if (["NotAllowedError", "PermissionDeniedError"].includes(e?.name)) {
            throw Object.assign(e, { cameraInfo: this._traduzir(e) });
          }
          await this._sleep(700); // deixa o driver respirar e tenta de novo
        }
      }
    }

    /* ★ 3. última cartada: sem restrição nenhuma */
    try {
      return await abrir(true);
    } catch (e) { ultimoErro = e; }

    throw Object.assign(ultimoErro || new Error("camera-indisponivel"), {
      cameraInfo: this._traduzir(ultimoErro)
    });
  },

  /* traduz o erro técnico pra português com instrução exata */
  _traduzir(e) {
    const n = e?.name || "";
    if (n === "NotAllowedError" || n === "PermissionDeniedError") {
      return {
        titulo: "Acesso à câmera bloqueado",
        msg: "O acesso não foi permitido. No Windows, abra <b>Configurações → Privacidade e segurança → Câmera</b> e ative <b>“Acesso à câmera”</b> e <b>“Permitir que aplicativos de área de trabalho acessem a câmera”</b>. Depois clique no botão de novo."
      };
    }
    if (n === "NotFoundError" || n === "DevicesNotFoundError") {
      return {
        titulo: "Nenhuma câmera encontrada",
        msg: "Este computador não tem webcam conectada. Ligue uma webcam (USB ou embutida) e clique no botão de novo."
      };
    }
    if (n === "NotReadableError" || n === "TrackStartError") {
      return {
        titulo: "A câmera está travada no Windows",
        msg: "A webcam existe, mas o Windows acusa ela como ocupada — mesmo sem nenhum programa aberto, isso é um <b>travamento de driver</b> (ou uma câmera virtual velha de OBS/Snap/ManyCam brigando com a real). O que resolve: <b>1)</b> reinicie o computador (destrava na quase totalidade dos casos); <b>2)</b> se for notebook, verifique se não tem tecla de bloqueio da câmera (F8/F10 com desenho de câmera) ativada; <b>3)</b> desinstale programas de câmera virtual se existirem."
      };
    }
    if (n === "SecurityError") {
      return {
        titulo: "Câmera bloqueada por segurança",
        msg: "O ambiente atual bloqueou o acesso. Reabra o app pelo atalho do EYE GATE na área de trabalho."
      };
    }
    return {
      titulo: "Não foi possível abrir a câmera",
      msg: "Erro inesperado (<b>" + (n || "desconhecido") + "</b>). Tente de novo com o botão abaixo; se persistir, reinicie o computador ou chame o suporte (contato no rodapé da tela de login)."
    };
  },

  /* painel de erro grande, com botão TENTAR DE NOVO */
  painelErro(info) {
    return (
      '<div style="max-width:430px;padding:22px 26px;background:#F7F7EC;border:2px solid #17140F;' +
      'box-shadow:4px 4px 0 #17140F;text-align:left;font-family:inherit">' +
        '<div style="display:flex;align-items:center;gap:10px;margin-bottom:10px">' +
          '<span style="display:inline-flex;width:30px;height:30px;border-radius:50%;background:#B21236;' +
          'color:#F7F7EC;align-items:center;justify-content:center;font-weight:800;font-size:17px;flex:none">!</span>' +
          '<b style="font-size:15px;color:#B21236;letter-spacing:.3px">' + info.titulo + '</b>' +
        '</div>' +
        '<p style="font-size:13px;line-height:1.55;color:#4A463C;margin:0">' + info.msg + '</p>' +
        '<button id="camRetryBtn" style="margin-top:16px;display:inline-flex;align-items:center;gap:8px;' +
          'background:#FEB914;color:#17140F;border:2px solid #17140F;border-radius:6px;' +
          'box-shadow:3px 3px 0 #17140F;padding:10px 18px;font-weight:800;font-size:12px;' +
          'letter-spacing:1px;cursor:pointer;font-family:inherit">↻&nbsp;TENTAR DE NOVO</button>' +
      '</div>'
    );
  }
};
