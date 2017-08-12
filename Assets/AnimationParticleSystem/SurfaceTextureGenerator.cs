using UnityEngine;

public class SurfaceTextureGenerator : MonoBehaviour
{
    public Material generator;
    public Mesh mesh;
    [Header("position texture from AnimationBaker")]
    public Texture vertPosTex;
    [Header("normal texture from AnimationBaker")]
    public Texture vertNormTex;
    public float deltaTime = 0f;
    public float animLength = 1f;
    public int texSize = 1024;

    public RenderTexture[] rts;
    RenderBuffer[] buffers;

    public Texture surfacePosTex { get { return rts[0]; } }
    public Texture surfaceNormTex { get { return rts[1]; } }

    private void Start()
    {
        CreateRts(texSize);
    }

    void CreateRts(int size)
    {
        rts = new RenderTexture[2];
        for (var i = 0; i < 2; i++)
        {
            var tex = new RenderTexture(size, size, 0, RenderTextureFormat.ARGBFloat);
            tex.filterMode = FilterMode.Point;
            tex.wrapMode = TextureWrapMode.Repeat;
            tex.Create();
            RenderTexture.active = tex;
            GL.Clear(true, true, Color.clear);
            rts[i] = tex;
        }
        buffers = new[] { rts[0].colorBuffer, rts[1].colorBuffer };

        var r = GetComponent<Renderer>();
        r.material.SetTexture("_PosTex2", surfacePosTex);
        r.material.SetTexture("_NormTex2", surfaceNormTex);
    }

    void Update()
    {
        SetProps();
        generator.SetPass(0);
        Graphics.SetRenderTarget(buffers, rts[0].depthBuffer);
        Graphics.DrawMeshNow(mesh, Matrix4x4.identity);
    }

    void SetProps()
    {
        generator.SetTexture("_PosTex", vertPosTex);
        generator.SetTexture("_NmlTex", vertNormTex);
        generator.SetFloat("_DT", deltaTime);
        generator.SetFloat("_Length", animLength);
    }
}