import re
from pathlib import Path

t = Path("lib/data/law/law_topic_world.dart").read_text(encoding="utf-8")
print("world lessons", len(re.findall(r"id: 'world_", t)))
c = Path("lib/data/law/law_catalog.dart").read_text(encoding="utf-8")
print("world wired", "LawTopicWorld.forSpec" in c)
