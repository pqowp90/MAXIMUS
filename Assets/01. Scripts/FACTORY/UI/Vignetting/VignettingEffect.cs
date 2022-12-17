using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class VignettingEffect : MonoBehaviour
{
    public bool isVignetting = false;
    public float nextTime = 0.1f;
    IEnumerator coroutine;
    // Start is called before the first frame update
    void Start()
    {
        PoolManager.CreatePool<Vignetting>("vignetting", this.gameObject);
        coroutine = VignettingCorutine();
    }

    // Update is called once per frame
    public void StartEffect(bool onoff)
    {
        if(onoff)
        {
            StartCoroutine(coroutine);
        }
        else
        {
            StopCoroutine(coroutine);
        }
    }
    private IEnumerator VignettingCorutine()
    {
        while (true)
        {
            {
                Vignetting vignetting = PoolManager.GetItem<Vignetting>("vignetting");
                Sequence seq = DOTween.Sequence();
                seq.Append(vignetting.transform.DOScale(1.05f, 0f));
                seq.Append(vignetting.transform.DOScale(0.9f, 1f));
                seq.Join(vignetting.image.DOFade(0f, 1f)).OnComplete(()=>{vignetting.gameObject.SetActive(false);});
                
                
            }
            yield return new WaitForSeconds(nextTime);
        }
    }
}
