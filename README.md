# SEC ETL

The SEC ETL (Extract, Transform, Load) pipeline is responsible for integrating and updating the Structured Eligibility Criteria (SEC) system, tying together both the SEC POC and NLP schemas, and maintaining the `sec` PostgreSQL database on a nightly schedule.

## Overview

- **Integration:** The ETL process connects the [SEC POC](sec_poc/) and [SEC NLP](sec_nlp/) modules, ensuring that clinical trial eligibility criteria and related NLP outputs are consistently loaded and updated in the database.
- **Nightly Updates:** The ETL job runs nightly, refreshing the database with the latest data and schema changes.
- **Quarto-Based Workflow:** The ETL is implemented as a [Quarto](https://quarto.org/) script (`etl.qmd`), which orchestrates the entire process and provides reproducible, documented workflows.

## Working with Git Submodules

This repository uses Git submodules to manage dependencies on the SEC POC and SEC NLP modules. To ensure you have the latest changes from these submodules, follow these steps:

1. **Initialize submodules (if cloning for the first time):**

   ```bash
   git submodule update --init --recursive
   ```

2. **Update submodules to the latest remote commits:**

   ```bash
   git submodule update --remote --recursive
   ```

3. **Check submodule status:**
   ```bash
   git submodule status
   ```

After updating, review any changes and commit the updated submodule references if needed. For more details, see the [Git Submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

## Deployment & Hosting

- **Production Hosting:** The ETL is hosted on the NCI's Posit Connect instance at [https://posit-connect-prod.cancer.gov/](https://posit-connect-prod.cancer.gov/), similar to the SEC POC application. This environment is different from the Appshare environment used by the SEC POC and Admin shiny apps. It offers 24x7 availability and larger resource allocations to accommodate the ETL workload.
- **Logging & Notifications:** After each ETL run, logs are sent via email to a configurable list of recipients. The recipient list is managed through the Posit Connect configuration.
- **Python Environment:** The ETL is designed for Python 3.9 to match the environment available on Posit Connect (newer versions may work but haven't been tested). While `uv` can be used for local development, `pip` is the package manager used during deployments.
- **Quarto Version:** Quarto CLI or extension version 1.4.x is required, matching the version on the remote server as closely as possible (newer versions may work but haven't been tested).

## Local Development

To run the ETL locally:

1. **Install Quarto CLI (version 1.4.x):**
   - Download from [Quarto releases](https://quarto.org/docs/download/).
2. **Set up Python 3.9 and dependencies:**
   - For local development, you may use [`uv`](https://github.com/astral-sh/uv) or `pip`:
     ```bash
     uv sync
     # or
     pip install -r requirements.txt -r requirements.dev.txt
     ```
3. **Run the ETL:**
   - Ensure quarto CLI is installed. See [`scripts/quarto-1.4.557-linux-arm64.sh`](scripts/quarto-1.4.557-linux-arm64.sh).
   ```bash
   quarto render etl.qmd
   ```

## Database & Configuration

- **Database:** The ETL populates and updates the `sec` PostgreSQL database, integrating data from both the SEC POC and NLP schemas.
- **Configuration:** Environment variables and database credentials are managed via Posit Connect for production deployments. For local development, ensure your environment matches the expected configuration.

## Additional Resources

- [SEC POC README](sec_poc/README.md): Details on the proof-of-concept application and database setup.
- [SEC NLP README](sec_nlp/README.md): Information on NLP integration and schema.
- [Quarto Documentation](https://quarto.org/docs/): For details on authoring and running Quarto projects.
