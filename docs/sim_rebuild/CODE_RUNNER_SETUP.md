# Code runner setup (Algorithm Arena)

The app never grades code itself. `codeJudge` (Cloud Function) builds a test
harness, sends it to an isolated sandbox, grades the hidden tests on the server
and writes the result to server-owned Firestore collections. Until a sandbox is
configured, Run/Submit answer **"Runner Unavailable — your code was not graded"**.

## 1. Run a Piston sandbox

[Piston](https://github.com/engineer-man/piston) runs each submission in an
isolated container with CPU, memory, process and network limits. It needs a
privileged Docker host, so use a small VM (Cloud Run cannot run it):

```bash
# Compute Engine: e2-small, Ubuntu, no public SSH needed if you use IAP
sudo apt-get update && sudo apt-get install -y docker.io
sudo docker run -d --name piston --restart unless-stopped --privileged \
  -p 127.0.0.1:2000:2000 -v /var/piston:/piston ghcr.io/engineer-man/piston
# install the two graded runtimes
curl -s -X POST localhost:2000/api/v2/packages -H 'content-type: application/json' -d '{"language":"python","version":"3.10.0"}'
curl -s -X POST localhost:2000/api/v2/packages -H 'content-type: application/json' -d '{"language":"node","version":"18.15.0"}'
```

Put a token check in front of it (the function sends the token as the
`authorization` header) and expose only HTTPS, for example with Caddy:

```caddyfile
runner.example.com {
  @authed header authorization "{env.RUNNER_TOKEN}"
  handle @authed {
    reverse_proxy 127.0.0.1:2000
  }
  respond 401
}
```

## 2. Configure and deploy

```bash
firebase functions:secrets:set CODE_RUNNER_URL   # https://runner.example.com
firebase functions:secrets:set CODE_RUNNER_KEY   # the RUNNER_TOKEN value
firebase deploy --only functions:codeJudge,functions:codeJudgeCatalog,firestore:rules
```

## 3. Keep the problem bank in sync

The server grades against `functions/code_judge/problems.json`, generated from
the app's Dart problem bank. `test/coding/problem_export_test.dart` fails when
they differ and writes the fresh file to `build/coding_problems.json`
(CI publishes it in the `ci-reports` branch). Copy it over the committed file.

To add GradeGlow-original problems, edit `tool/arena_originals/problems.py`
and run `python3 tool/arena_originals/gen_arena_originals.py`; expected
outputs are computed by the reference solutions, and
`functions/test/code_judge.test.js` runs both references through the judge.

## Limits

| Limit | Value |
|---|---|
| Run time (all cases together) | 6 s |
| Memory | 256 MB |
| Code size | 64 KB |
| Rate | 20 runs per student per minute |
| Graded languages | Python 3, JavaScript (others are labeled "not graded yet") |
