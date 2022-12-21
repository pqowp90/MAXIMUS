using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.EventSystems;
using DG.Tweening;
using UnityEngine.UI;
using UnityEngine.Playables;


public class TitleButton : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    private GameObject _selectPanel;
    [SerializeField] private PlayableDirector _director;
    [SerializeField] private AudioClip _swapSound;
    [SerializeField] private AudioClip _clickSound;
    [SerializeField] private GameObject _cat;
    [SerializeField] private GameObject explosion;

    [SerializeField] private Image _loadingPanel;

    private void Awake() {
        _selectPanel = transform.Find("SelectPanel").gameObject;
        _loadingPanel?.gameObject.SetActive(false);
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        _selectPanel.SetActive(true);
        _selectPanel.transform.localScale = Vector3.one * 0.9f;

        DOTween.defaultTimeScaleIndependent = true;
        Sequence seq = DOTween.Sequence();
        seq.Append(_selectPanel.transform.DOScale(Vector3.one * 1.1f, 0.1f));
        seq.Append(_selectPanel.transform.DOScale(Vector3.one, 0.1f));

        SoundManager.Instance.PlayClip(SoundType.UI, _swapSound);
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        _selectPanel.SetActive(false);
    }

    public void SceneLoadClick(int num)
    {
        SoundManager.Instance.PlayClip(SoundType.UI, _clickSound);
        _director.Play();
        SceneLoad.Instance.LoadScene(num);
        StartCoroutine(OnCat());
        
    }
    private IEnumerator OnCat()
    {
        _cat.SetActive(false);
        yield return new WaitForSeconds(3.75f);
        _cat.SetActive(true);
        
    }
    public void Explosion()
    {
        Instantiate(explosion, _cat.transform.position, Quaternion.identity);
    }

    public void Options()
    {
        MenuUi.Instance.Option(true);
        SoundManager.Instance.PlayClip(SoundType.UI, _clickSound);
    }

    public void GameExit()
    {
        SoundManager.Instance.PlayClip(SoundType.UI, _clickSound);

#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#else
        Application.Quit();
#endif
    }
}
