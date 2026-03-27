# LinkedIn Outreach — Secuencia 5 Touchpoints para Asesorías Laborales

**Target:** Asesoría laborales en España (empresas de 10-200 empleados)
**Objetivo:** Agendar llamada de discovery (30 min con Calendly)
**Canal:** LinkedIn InMail + Conexiones personalizadas

---

## 🔷 TOUCHPOINT 1 — Hook (Conexión)

**Tipo:** Conexión personalizada (no InMail frío)
**Timing:** Día 0
**¿Por qué primero?:** Establece relación antes de pedir algo

**Texto de conexión:**

> Hola [Nombre], veo que gestionáis [_tipo de actividad: nóminas, RGPD laboral, prevención de riesgos_] para vuestros clientes. Me dedico a ayudar a asesorías como la vuestra a automatizar procesos repetitivos — para que podáis atender más clientes sin más horas. ¿Conectamos?

**Variables personalization:**
- `_TIPO_ACTIVIDAD_` → según sector/descripción del perfil
- `[Nombre]` → nombre del contacto (dueño o responsable)

**Nota:** Sin emoji en conexión. Máximo 300 caracteres. Esperar 7 días antes del primer InMail.

---

## 🔷 TOUCHPOINT 2 — Value Prop

**Tipo:** InMail (después de aceptar conexión)
**Timing:** Día 7 post-aceptación
**Objetivo:** Presentar AGENIA y el problema que resolvemos

**Asunto:** [Nombre], ¿cuántas horas invertís al mes en [_proceso repetitivo_]?

**Texto:**

> Hola [Nombre],
>
> ¿Cuántas horas al mes dedicáis a [_gestionar nóminas mensuales / responder consultas laborales repetitivas / preparar documentación RGPD_] para vuestros clientes?
>
> En AGENIA trabajamos con asesorías laborales como la vuestra automatizando esos procesos que comen tiempo: alta/baja empleados, actualizaciones de convenio, parsing de nóminas, respuestas estándar a consultas frecuentes.
>
> El resultado: más clientes atendidos, misma plantilla.
>
> ¿Tienes 15 minutos esta semana para mostrarte cómo funciona? Tenemos un Calendly abierto: [ENLACE_CALENDLY]
>
> Un saludo,
> [Tu nombre]

**Variables:**
- `_PROCESO_REPETITIVO_` → lo más relevante para el contacto
- `[ENLACE_CALENDLY]` → Calendly configurado
- `[Tu nombre]` → nombre del agente o Elvis

---

## 🔷 TOUCHPOINT 3 — Social Proof

**Tipo:** InMail de seguimiento
**Timing:** Día 14 (7 días después del Touchpoint 2)
**Objetivo:** Generar credibilidad con prueba social concreta

**Asunto:** Re: [Nombre], ¿cuántas horas invertís al mes...?

> Hola [Nombre],
>
> Te escribo de nuevo porque me acorde de algo: uno de nuestros clientes — una asesoría en Barcelona con [_X clientes_] — automatizó el proceso de [_alta/baja de empleados_] con nosotros. Antes tardaban [_Y horas/semana_]; ahora, [_Z minutos_].
>
> [_Quote o dato concreto si lo hay_]
>
> Es una asesoría similar a la vuestra en tamaño y modelo. Por eso pensé que podría encajar.
>
> ¿Qué te parecería verlo en acción? → [ENLACE_CALENDLY]
>
> Un saludo,
> [Tu nombre]

**Social proof a usar (placeholder — reemplazar con dato real cuando tengamos clientes):**
> "María, responsable de una asesoría en Valencia con 80 empresas clientes, redujo un 60% el tiempo de gestión de nóminas mensuales en el primer mes."

---

## 🔷 TOUCHPOINT 4 — Urgencia

**Tipo:** InMail con urgencia suave
**Timing:** Día 21 (7 días después del Touchpoint 3)
**Objetivo:** Crear razón para actuar ahora

**Asunto:** [Nombre] — antes de que cambie de enfoque

> Hola [Nombre],
>
> Te escribo porque estoy preparando la浊 ronda de conversaciones con asesorías en [_tu ciudad/región_] para este mes, y me gustaría incluir la tuya si encaja.
>
> He visto que [_mencionar algo específico del perfil o reciente_ — si no hay, omitir esta frase].
>
> Si no es buen momento, dime y lo dejamos aquí. Pero si estáis invirtiendo más horas de las que quisierais en [_gestión de nóminas / temas administrativos repetitivos_], puedo mostraros algo que puede cambiar eso.
>
> → [ENLACE_CALENDLY] (15 min, sin compromiso)
>
> ¿Esta semana o la que viene?
>
> Un saludo,
> [Tu nombre]

---

## 🔷 TOUCHPOINT 5 — Calendly CTA Final

**Tipo:** InMail último intento
**Timing:** Día 28 (7 días después del Touchpoint 4)
**Objetivo:** Cerrar con CTA directo y claro

**Asunto:** [Nombre], último mensaje desde mi lado

> Hola [Nombre],
>
> Solo confirmar que mi disponibilidad para AGENIA sigue abierta este mes. Si alguna vez os surge la necesidad de [_automatizar gestión de nóminas, altas/bajas, o cualquier proceso repetitivo_], aquí estoy.
>
> Podéis reservar directamente aquí → [ENLACE_CALENDLY]
>
> Gracias por vuestra atención,
> [Tu nombre]

---

## 📋 Checklist de Personalización por Contacto

Antes de enviar cada mensaje, verificar:

- [ ] **Nombre** correcto del contacto
- [ ] **Empresa** coincide con target (asesoría laboral, 10-200 empleados)
- [ ] **Personalización** — 1 detalle específico del perfil o empresa
- [ ] **CTA correcto** — Calendly link actualizado
- [ ] **Timing** — esperar el intervalo correcto entre touchpoints
- [ ] **No enviar** si el contacto ya respondió o indicó no interés

---

## ⚙️ Automatización Recomendada (n8n)

Esta secuencia se puede automatizar parcialmente:

1. **Enriquecimiento** de leads con cargo/rol (dueño, RRHH, admin)
2. **Verificación** de que el contacto no haya respondido antes
3. **Escalado temporal** entre touchpoints (7 días cada uno)
4. **Tracking** de respuestas y CTAs ( Calendly clicks)
5. **Pausa** si el lead responde cualquier mensaje

**Pipeline n8n propuesto:**
```
LinkedIn Lead → Check if already in sequence 
  → Touch 1 (Conexión) → Wait 7 days
  → Touch 2 (Value Prop) → Wait 7 days
  → Touch 3 (Social Proof) → Wait 7 days
  → Touch 4 (Urgencia) → Wait 7 days
  → Touch 5 (CTA Final) → End / CRM update
```

---

## 📁 Archivo Base

> **Nota:** `01-linkedin-outreach.md` no existía en el workspace en el momento de ejecutar esta tarea. Esta secuencia se ha construido desde cero basándose en las directrices descritas en el issue: Hook, Value prop, Social proof, Urgencia, Calendly CTA. Cuando se encuentre o cree el archivo base, actualizar este documento con su contenido.

**Creado:** 2026-03-27 por Totin (CEO Agent) — Paperclip Run: `0dd29909-7f7b-4312-8dd0-073007f0c9cc`
**Issue:** AGE-5 — "Preparar secuencia outreach LinkedIn - 5 touchpoints"
