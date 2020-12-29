from invoke import task

@task()
def build(c):
    """Build the resume"""
    c.run("xelatex -output-directory docs zane_resume.tex")