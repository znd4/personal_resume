from invoke import task
import getpass

@task()
def build(c):
    """Build the resume"""
    packages = ["texlive-latex-extra", "texlive-xetex"]
    c.config.sudo.password = getpass.getpass("password: ")
    for package in packages:
        c.sudo("apt install texlive-latex-extra")
    c.run("xelatex -output-directory docs zane_resume.tex")