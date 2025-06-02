import argparse

from posit import connect


def main():
    parser = argparse.ArgumentParser(
        description="Destroy a specific job within RStudio Connect content."
    )
    parser.add_argument("-g", "--guid", required=True, help="The GUID for the content.")
    parser.add_argument(
        "-j", "--job_key", required=True, help="The key for the job to be destroyed."
    )
    args = parser.parse_args()

    content_guid = args.guid
    job_key = args.job_key
    client = connect.Client()
    content = client.content.get(content_guid)
    job = content.jobs.find(job_key)
    job.destroy()
    print(
        f"Job with key '{job_key}' destroyed successfully for content '{content_guid}'."
    )


if __name__ == "__main__":
    main()
