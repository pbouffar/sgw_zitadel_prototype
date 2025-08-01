# config.py

SSL_ENABLED=False

if SSL_ENABLED:
    SGW_ZITADEL_DEMO_SERVER = "https://localhost:8090"
    CLIENT_CERT_PATH = "client.crt"
    CLIENT_KEY_PATH = "client.key"
else:
    SGW_ZITADEL_DEMO_SERVER = "http://localhost:8090"

ZITADEL_SERVER = "http://localhost:8080"

TOKEN_URL = f"{ZITADEL_SERVER}/oauth/v2/token"

PUBLIC_API = f"{SGW_ZITADEL_DEMO_SERVER}/public/hello"
SECURED_API = f"{SGW_ZITADEL_DEMO_SERVER}/secured"
DOWNSTREAM_API = f"{SGW_ZITADEL_DEMO_SERVER}/call-downstream"

PROJECT_ID="330021820281431898" # SGW_Project_Cisco. The Zitadel project's Resource ID.

# --- Configuration for Client Credentials Grant ---
CLIENT_ID = "sgw_client_app"
CLIENT_SECRET = "bhwbF4APgAclItV1Idi8YxyKDTYJKO0WHDulXsEWqlnvajDpHMyYe3sGoQ1S84hP"

CLIENT_ID_2="sgw_pierre"
CLIENT_SECRET_2="5OQ8eh6PQLjzcJKhMSSPVC7JXAbpcveGMm0A4qsQAiVDUHxHanrSE3ri4UZ2Z4gw"

# --- Configuration for JWT Bearer Grant ---
SERVICE_USER_ID = "329282488167868250"
KEY_ID = "329282866460534618"
PRIVATE_KEY='''-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEApL+VDKU+UGpsIj2go33uJ/+U1IOIE2fjS8RLs1Q/EvzL5+Wj
Y3ruansDKNm6nA6oNmsJTJXckDYZLnc1Rc2EOb1eiiyhL166p9aDd4oxZV9BsRfu
lPAgff5rKx8c5xdarTSGbFyQ3lsdXPsfc/DGmj3RdaCnZBWlCDeSAy5AZrFZZxFZ
Zl6UGzThLEVOEiaK3k+LX0+jzWR3yjdsoFdCq8dI/gG3/NLlQU/wXF83WB5CPRHg
MqC1V+xYdTdfNALbe8IzvlAeVu+ULWExyg3ZYoC6JRSIV2PTIy0Lopi9J36VYCk/
a1+0JGTvuvRGf0DzDn7pwth8KEkbHdFAoWV6LQIDAQABAoIBAANgqlw6gmG2O/SG
pUITDF5Mj/K8iZq1lH0ZyG5rKbD96JVmBgUhJ8ucSa8g4rqWOTq/fnl6pi15KD0e
W4r3F/ZHTlhF3ExWma3V/jN0COfGT5EVEluCVzyjX2U1wrJS2RV0iSqJrbypSzgY
n3kRbXjvD6EBWSDBcRFyx/1I0L5qNE+tMCQOa9eI7c61rgUfbjPYn4iPe5DTBU9B
zhdn5VG+iLsqEzUX6H+N3cUV/NKltK9mekCCsgsUgIL6xMWgYRzduSUi4K1K9ngb
UBEZKBPoRNLkzK1NQ8WgoLm72eVrkvBy4UR1w2eAYRBQU3eaQ7UV+2GCCTUPWTEV
sYplRXECgYEAz4cD8QqmVZex+gSsU+rJK/JtDKjoVkaoDRmqCPYeDd0BbVX8ulMg
/W09aQ8DpTOH/wR0MZJkCvFqVWO1NViF0rJ3IMkDvqF8Rd97yPYUWmMJYVcKnQva
bEiOl0Wam2kUQ6PBv3zKV6wd0imr8yq+wdBiqjJz4Rhe9WmtxZhacDUCgYEAyzqe
T0yXpqW+qiBhh/fF6RaugLskf2Beq8b7PQKqCDJaeiayPXK8g/na6pP+6ns90xAL
SxYPEMItMo55sJqrGOnc7ypC/9QWuKOn1bZjnBLS4onhDs9SSCVjzIVcMqDTO8ns
k5DmUg59TyoGY/ZXiflbIUV/joAl7RjK8cBJERkCgYAWvtaYwbEPaovwOjjlDbO0
5GI9Y/nrEt1yaiCv0MHkhReV8zm69keEX0e+zw14OtiqA8P0dvYOGP2tlDsVOLma
KUNTTZTifPKQ+fioQwhiC77Ic3DPW7A59A3k2JUkeXTmIPmoUjYfO9cc5MJa6ZF0
zrExtEvtHO2zejy4joVDDQKBgQCD6aGWYWXSIqVWsjv8UISi3jkYj+CJ2Vi58Sdk
m5UYSu7VeMabAh2BIK3LM5L0Slh/5lseOsw+mXtS5I3yZwKF4k6o4uqoOdchtACd
xIx1YvaFWu+9eC61a6eSukF1D1Ts6w1nX1dQjd0ihGmvetepVDSlrQG10lJLypr4
PlJvCQKBgCl9chLCeuw9fF3yQITNNVnDM0yXaz5n0MPCuaciCLHI2G1fENzz/S3f
5Re6i4aO4EnltCv0HSjxsFubvEkVBN8T+OQQE7SdMHpZgOD46NgZAkI2Uhip+dPK
DId1QwLyIkXZGEC9IZIEHWsfb+4QKI3HRH517sTrELM6Z3Xzmnij
-----END RSA PRIVATE KEY-----'''

SERVICE_USER_ID_2 = "330022031053596506"
KEY_ID_2 = "330026715084531546"
PRIVATE_KEY_2='''-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAsvhDk9YpgPTzDpv7NdDL4M6+hqBagA7x8oHFz8CqfHb9vrn8
kS1nOmH+8SoPQMf8ATugMU7TjkZP0Dgt8ICfhZYdsYd8j+MRUytRwqz6ZGdy+OAS
OEghaoeZC9uNHxQkCgRNrdJuqZmZgmxTKMzfomZ74qmLsV+bdgZh7PkJnIm5oCXV
9dV2qloMwIoGEV/c0QbbixQ/p+Nznlldj/bmVxdLVoOBZF6rFxuh8uyyVKNRR7fD
Gq+adAHECh8VY7LcuXGDlqCWNgFrEArbNH6abo+V7Lkr+JxUBgDkQvKWCt/Ohw33
HSaGdRdJ6bFKT01OLNnxStl4roajw3kbW27S5wIDAQABAoIBAAeyYqGgg79uiWd2
8NpTJPmBmrMKgWnheqlNyHaTWCGrMmV59TE/LSHXJhI0F1zXXPCmolCMjc+gGX2g
dOVTesjReGxyobpEbzHO+qCvNMONqWWnqVDvVTSSKVRXuF1+TcB6h+ayVp0HpJD1
3Ku0B+ghlTFdzkquDG8KfjqlSTMIrM3VfuE10JgqvU2ZIvf4IPg4RgSYOOn+amp7
oZN8cqgN4kMZzq4EN3/nSf5hZd63bXRp/CGLzQy07YF5I+cOaAlRARheabKE2WyP
KwGe/toQkemvik+spQzcMelVXkNLUYNcsG/IxzQLSCDlzvuCBMhL9vjuFiTJHecp
r0pyliECgYEA6dmwyuLFMQtrF72c6CZqmJxumUDl91hGfLVletVn6htt9AiHbx9V
ybhJvHwyH8Viuw9c/DW5l9E+nKypPTO2IWO3D0mj4qzMQU8PXMtC/AzougcfZN9h
xyVB+FEK0nNvyYQTN7B4GIdKp3s0swQJp24b1rCDzRHEWyPRnpz9++ECgYEAw+vZ
7yvjMYEFQhgYQRqt+L2iAFw73Evb9lQr4EQGdQjifSLVt13LepZKNT2+aPMi9g78
2zEU1n4R1lrnZC6Bg7pFkOxYS7mpEL0oxAzcNLJzaBzfwuakKdQ8DwCMeQGzEYeS
FhPJRTVfn+rhyOcr0/LyTks3vFYduxZnjFq458cCgYADqEz0j2FoJ/aP035dvyQR
qPit2u791Fqd3rRsnGPYrH8mvu9nVIUh94jnssWR66Nkq5PXuftiHXquNqEa/PEP
SqD1U0CF7g/vwY3K9L7idE07g5sBF+FOnQ2QFaxmqDmKXE90ooTuVUdcoTesyRZh
kP5MeExHa8y3ZDMGGQx74QKBgBzCPhdRheP6YF83UjgcRnVAwMr0vwSzTfJ2oIom
8huz1iswNdbYucmgzfvKuGyHZBZiVNOH/NsPXmbsqRKXkQNZEGUZjExxUFPYsGc2
zAwgNbiOpHnjiS1qrfY1ymjoyvRDxjnfZaf3EbZTsBjhdhmCi/baK7BFo8+WllSP
7Jx5AoGABt1h5oodmormv0dIfmSpZf8yGQguvNRZwI49tCeNLhoOctoOs3uuBtXA
bcNGm243L4+GAFSlFolGoShhTLYbOTdXbsaAERe2xpCDGycflv2HkGctloBirEbA
3Gx47kK6hN8LSyIVCETFOH+lln8SXbPFxjLo4L+AI6dKWeSOa6s=
-----END RSA PRIVATE KEY-----'''



