from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import subprocess
import os

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class DeployRequest(BaseModel):
    project: str
    repo: str

@app.get("/")
def read_root():
    return {"message": "Deploy Panel API is running"}

@app.post("/deploy")
def deploy(request: DeployRequest):
    project = request.project.strip()
    repo = request.repo.strip()
    
    if not project:
        raise HTTPException(status_code=400, detail="Project name tidak boleh kosong")
    
    if not repo:
        raise HTTPException(status_code=400, detail="Repository URL tidak boleh kosong")
    
    if not repo.startswith("http"):
        raise HTTPException(status_code=400, detail="Repository URL harus dimulai dengan http/https")
    
    deploy_script = "/app/deploy.sh"
    
    if not os.path.exists(deploy_script):
        raise HTTPException(status_code=500, detail="deploy.sh tidak ditemukan")
    
    try:
        result = subprocess.run(
            [deploy_script, project, repo],
            capture_output=True,
            text=True,
            timeout=300
        )
        
        output = f"=== STDOUT ===\n{result.stdout}\n\n=== STDERR ===\n{result.stderr}\n\n=== EXIT CODE ===\n{result.returncode}"
        
        if result.returncode == 0:
            return {"success": True, "log": output}
        else:
            return {"success": False, "log": output}
            
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=500, detail="Deploy timeout (melebihi 5 menit)")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
