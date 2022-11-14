using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SizeByThis : MonoBehaviour
{
    [SerializeField]
    private RectTransform thisSize;

    private void OnGUI() {
        transform.localScale = thisSize.localScale;
    }
    private void Update() {
        transform.localScale = thisSize.localScale;
    }
}
