NYDATABAS DUMP!
set -a; source .env; set +a
bash scripts/dump_all.sh


Starta om fastApi backend DB:
cd /home/oden/Wisdom/backend
nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload > ../backend_uvicorn.log 2>&1 &


Till Dev miljö:
python3 -m venv .venv && source .venv/bin/activate


# 1. Kolla vilken process som håller porten
lsof -i :8000

# 2. Döda processen (ersätt PID med det du får från lsof)
kill <PID>

# (om flera processer svarar, kör kill på dem också)

# 3. Starta backenden igen
cd ~/Wisdom/backend
poetry run uvicorn app.main:app --reload

STARTA ANDRIOD:

flutter devices

flutter emulators --launch Pixel_7_API34

flutter run -d emulator-5554
