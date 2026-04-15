from typing import List

from edu.stanford.cmed.devcli.model.ArtifactEntryReport import ArtifactEntryReport


class ArtifactReport:

    def __init__(self) -> None:
        self.entries: List[ArtifactEntryReport] = []

    def add_entry(self, entry_report: ArtifactEntryReport):
        self.entries.append(entry_report)

    @staticmethod
    def get_caption():
        caption = 'Artifacts'
        return caption
