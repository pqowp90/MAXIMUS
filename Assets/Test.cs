using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    [SerializeField]
    private int id;
    [SerializeField]
    private ConveyorBelt conveyorBelt;
    // Start is called before the first frame update
    void Start()
    {
        //gameObject.AddComponent<ConveyorBelt>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    [ContextMenu("컨베이어벨트에 삽입")]
    public void TestFunc()
    {
        if(!conveyorBelt)
            conveyorBelt = GetComponent<ConveyorBelt>();
        conveyorBelt.Item = ItemManager.Instance.DropItem(Vector3.zero, id);
        
    }
}
