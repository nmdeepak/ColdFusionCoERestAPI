# Enterprise ColdFusion & Lucee REST API

A lightweight, scalable RESTful API application built with **ColdFusion / Lucee** and managed via **CommandBox**. This API supports modular endpoint versioning (v1/v2), CRUD operations for task management, and seamless integrations with modern frontends (e.g., React/Redux).

---

## 🚀 Features

* **Multi-Engine Support:** Seamlessly runs on both Adobe ColdFusion (2021/2023) and Lucee (5/6) via CommandBox.
* **API Versioning:** Supports clear version separation (`/api/v1/...` and `/api/v2/...`).
* **Clean URL Rewriting:** Uses CommandBox Tuckey URL rewrites to omit `/rest/` servlet paths.
* **Lucee Cache Auto-Configuration:** Built-in programmatic memory caching in `Application.cfc` to avoid Lucee default cache errors.
---

## 🛠️ Tech Stack & Requirements

* **CLI & Server Manager:** [CommandBox](https://www.ortussolutions.com/products/commandbox) (v5.x or higher)
* **CFML Engines:** Adobe ColdFusion 2021/2023 or Lucee 5/6
* **Database:** MySQL / MSSQL (Configured via `Application.cfc` datasources)

---

## DATABASE MySQL
Table creation script
CREATE TABLE `tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


## 📂 Project Structure

```text
restApiApp/
├── Application.cfc          # Main app setup, CORS, and REST initialization
├── server.json              # CommandBox server engine configuration
├── urlrewrite.xml           # Tuckey URL rewrite rules for clean routes
├── api/
│   ├── v1/
│   │   └── Taskapi.cfc      # Version 1 REST endpoint implementation
│   └── v2/
│       └── Taskapi.cfc      # Version 2 REST endpoint (extends/reuses v1)
└── README.md
