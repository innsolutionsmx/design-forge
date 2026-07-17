---
name: revisar-mejoras
description: >
  Recorre el backlog de mejoras del plugin design-forge (seguimiento-de-mejoras.md),
  ayuda a implementarlas una por una y las tilda al terminar. Actívala al abrir
  sesión en el repo design-forge cuando el hook SessionStart avise que hay
  pendientes, o cuando el usuario diga "revisemos las mejoras", "qué mejoras hay",
  "/revisar-mejoras", "procesá el backlog de design-forge".
---

# Revisar mejoras pendientes de design-forge

Sos la contraparte de CONSUMO del canal de handoff. Las mejoras llegaron acá desde
otras sesiones (vía la skill personal `design-forge-mejora`) y quedaron en el
backlog. Tu trabajo: procesarlas con criterio, no ejecutar a ciegas.

## Archivo

```
seguimiento-de-mejoras.md   (raíz del repo design-forge)
```

Pendientes = items `- [ ]` bajo `## Pendientes`. Hechas = `- [x]` bajo `## Hechas`.

## Flujo

1. **Leé el archivo completo.** Listá los pendientes con su título, contexto,
   mejora propuesta e impacto.
2. **Priorizá y mostrá.** Ordená por impacto (alto → bajo) y presentale al usuario
   el panorama: cuántas hay y cuál conviene atacar primero. No arranques a codear
   sin que el usuario elija.
3. **Por cada mejora elegida:**
   - Confirmá que entendés el gotcha real (releé el contexto; si algo no cierra,
     preguntá antes de tocar código).
   - Proponé el enfoque técnico ANTES de implementar. Recordá: conceptos antes que
     código.
   - Implementá siguiendo las convenciones de design-forge (mirá `commands/`,
     `skills/pipeline/`, `docs/` para el estilo del plugin).
   - Al terminar, **movés la entrada de `## Pendientes` a `## Hechas`**, cambiás
     `- [ ]` por `- [x]` y agregás ` · cerrada: <YYYY-MM-DD>` al final del título.
4. **Cierre.** Cuando no queden pendientes (o el usuario pare), resumí qué se
   implementó y recordá commitear en el repo design-forge.

## Reglas

- **No borres** entradas: se mueven a Hechas, no se eliminan (traza histórica).
- **No implementes sin aprobación** del enfoque — el usuario dirige, vos ejecutás.
- Una mejora puede necesitar su propia rama `feat/` en design-forge; respetá el
  gitflow del repo si aplica.
- Si una mejora ya no tiene sentido (obsoleta), proponé descartarla moviéndola a
  Hechas con nota `descartada: <motivo>` en vez de dejarla colgada.
