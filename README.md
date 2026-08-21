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
```
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
```
🚦 Getting Started1. PrerequisitesEnsure CommandBox is installed on your machine:Bash# Windows (Winget)
winget install OrtusSolutions.CommandBox

# macOS (Homebrew)
brew install commandbox
2. Clone & Start the ServerClone the repository and start the server using CommandBox:Bash# Clone repository
git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
cd your-repo-name

# Start server (Defaults to configuration in server.json)
```box server start```
🔄 Engine Switching (CommandBox)You can test or switch between Lucee and Adobe ColdFusion runtimes with a single CLI command:Bash# Run on Lucee 6 (Default)
```box server start cfengine=lucee@6```

# Switch to Adobe ColdFusion 2023
```box server start cfengine=adobe@2023```

# Switch to Adobe ColdFusion 2021
```box server start cfengine=adobe@2021```
Note: Stop the server using box server stop before switching engines.
📡 API EndpointsBase 

1.GET,/api/v1/tasks,Get list of all tasks,None
2.GET,/api/v1/tasks/{id},Get task by numeric ID,Path: {id}
3.POST,/api/v1/tasks,Create a new task,"Body: {""title"": ""String"", ""status"": ""String""}"
4.PUT,/api/v1/tasks/{id},Update an existing task,"Path: {id}, Body: {""title"": ""String""}"
5.DELETE,/api/v1/tasks/{id},Delete a task,Path: {id}

🔧 Re-initializing REST Mappings
If you update REST annotations (restpath, httpMethod, restargsource) in your CFCs, trigger a REST router cache flush:

Via CLI:

Bash
box eval "restInitApplication(expandPath('./api/v1'), 'v1')"
Via Browser:
Navigate to http://127.0.0.1:8080/?reloadREST=1

🤝 Contributing
Fork the ProjectCreate your Feature Branch (git checkout -b feature/NewFeature)Commit your Changes (git commit -m 'Add some NewFeature')Push to the Branch (git push origin feature/NewFeature)Open a Pull Request
