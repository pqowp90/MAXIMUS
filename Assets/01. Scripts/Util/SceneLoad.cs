using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using DG.Tweening;

public class SceneLoad : MonoSingleton<SceneLoad>
{
    [SerializeField] Image _loadPanel;
    [SerializeField] GameObject _loadingBar;
    [SerializeField] Slider _loadSlider;

    public override void Awake() {
        base.Awake();
        _loadPanel.gameObject.SetActive(false);
        _loadPanel.DOFade(0, 0);
        _loadingBar.gameObject.SetActive(false);
        _loadSlider.value = 0;
    }

    private void Start() {
        DontDestroyOnLoad(this);
    }

    public void LoadScene(int sceneId)
    {
        _loadPanel.gameObject.SetActive(true);

        Sequence seq = DOTween.Sequence();
        seq.Append(_loadPanel.DOFade(1, 0.2f));
        seq.AppendCallback(()=>_loadingBar.gameObject.SetActive(true));
        seq.AppendCallback(()=>StartCoroutine(Loading(sceneId)));
    }

    private IEnumerator Loading(int sceneID)
    {
        AsyncOperation op = SceneManager.LoadSceneAsync(sceneID);
        op.allowSceneActivation = false;
        while(!op.isDone)
        {
            float value = Mathf.Clamp01(op.progress / 0.9f);

            _loadSlider.value = value;

            yield return null;
            if(value >= 1)
            {
                yield return new WaitForSeconds(3f);
                _loadSlider.value = 1;
                FindObjectOfType<TitleButton>().Explosion();
                break;
            }
            
        }
        

        Sequence seq = DOTween.Sequence();
        seq.AppendCallback(()=>_loadingBar.gameObject.SetActive(true));
        seq.Append(_loadPanel.DOFade(0, 0.2f));
        seq.AppendCallback(()=>_loadPanel.gameObject.SetActive(false));
        seq.AppendCallback(()=>_loadingBar.gameObject.SetActive(false));
        yield return new WaitForSeconds(3f);
        op.allowSceneActivation = true;
    }
}
