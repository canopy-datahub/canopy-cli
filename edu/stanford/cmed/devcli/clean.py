import typer

from edu.stanford.cmed.devcli import clean_maven

app = typer.Typer(no_args_is_help=True)
app.add_typer(clean_maven.app, name="maven")
