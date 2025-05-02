# CRM Builder Project Overview

## What It Is

**CRM Builder** is a no-code, web-based builder that allows users to visually design and deploy data-driven CRM applications without writing code. It provides a drag-and-drop interface to place tables, forms, and charts, bind them to a Supabase backend, preview live data, and export a working app.

## Who It’s For

* **Product Managers & Business Users:** Rapidly prototype internal tools and dashboards without developer help.
* **Startup Founders & SMEs:** Launch a minimum viable CRM or data app quickly.
* **Citizen Developers:** Non-technical users who need custom data interfaces.

## Key Features

1. **Visual Canvas**

   * Infinite grid with snap-to-grid placement
   * Palette of widgets: Table, Form, Chart
   * Drag-and-drop placement and resizing
2. **Data Binding**

   * Connect to Supabase tables via secure RPCs
   * Select columns to display in tables or fields in forms
   * Live preview of data (CRUD form & DataTable)
3. **Widget Properties Panel**

   * Edit rows-per-page, toolbar visibility, sorting, search
   * Bind forms to tables and pick fields
4. **Persistence & Projects**

   * Save canvas layout & widget props (JSON) to Supabase
   * Auto-load saved projects on startup
5. **Export Pipeline**

   * Generate static web bundle (free) or full Flutter source ZIP (paid)
   * Integrate with Edge Functions for code generation
6. **User Management & Workspaces**

   * Supabase auth (magic link, OAuth)
   * Multi-tenant workspaces and projects
7. **Undo/Redo & Delete**

   * Keyboard shortcuts for undo (⌘Z) / redo (⌘⇧Z)
   * Delete selected widget

## Technical Stack

* **Frontend:** Flutter Web + Desktop (Material 3)
* **State Management:** Provider + GetIt
* **Backend:** Supabase (PostgreSQL, Auth, Edge Functions)
* **Services:** fpdart-wrapped WorkspaceService & ProjectService
* **Monorepo:** Managed with Melos
* **Charts:** `charts_flutter_next` for future Chart widget

## Repo Structure

```
crm_builder/
├─ apps/
│  └─ builder_web/          # Flutter web editor
│     ├─ lib/
│     │  ├─ main.dart
│     │  └─ ui/builder/      # Canvas, palette, panels, dialogs
│     └─ pubspec.yaml
├─ packages/
│  ├─ core/                 # Supabase client, services, models
│  └─ widgets_palette/      # PaletteItem, props models, preview widgets
├─ supabase/                # CLI config, migrations, RPC functions
├─ melos.yaml               # Workspace config
├─ spec.json                # Local Supabase env vars
└─ .vscode/launch.json      # Debug config
```

## Milestones Completed

1. **Setup & Supabase Connection**
2. **Palette & Canvas Drop**
3. **Select & Properties Panel**
4. **Data Binding Wizard**
5. **Live Data Preview**
6. **Save & Load Layout**
7. **Move & Resize**
8. **Delete Widget**

## Roadmap & Next Steps

* **Multi-Select & Batch Delete**
* **Form Widget CRUD Preview**
* **Chart Widget (Bar/Line)**
* **Export App (static & source)**
* **Auth UI & Workspace Selector**
* **UI Polish & Theming**

---

*Generated as a reference for the Cursor-based development workflow.*
