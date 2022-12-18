using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

public class Player : MonoBehaviour, IDamageable
{
    private float _hp = 100;
    private bool _isOpenBag;
    public TMP_Text ammoText;
    public ItemDB inventory;
    private PlayerAttack attack;
    public PlayerMovement playerMove;


    [Header("Item")]
    [SerializeField] private LayerMask _itemLayer;
    [SerializeField] private float _itemFindRadius = 1f;

    #region Mining
    [Header("Ore")]
    [SerializeField] private LayerMask _oreLayer;
    [SerializeField] private float _oreSearchRadius = 5f;
    [SerializeField] private AudioClip _mineClip;

    private Ore mineOre;
    
    public bool isMine = false;
    private bool _isFindOre = false;
    private bool _isMining = false;
    #endregion

    [Header("Keybinds")]
    public KeyCode reloadKey = KeyCode.R;
    public KeyCode bagOpenKey = KeyCode.E;
    public KeyCode miningKey = KeyCode.F;

    public UnityEvent<float> OnDamageTaken { get; set; }
    public float Health { get => _hp; set => _hp = value; }

    private void Start()
    {
        attack = GetComponent<PlayerAttack>();
        playerMove = GetComponent<PlayerMovement>();
       
    }

    private void Update()
    {
        SearchItem();
        SearchOre();
        SwapWeapon();
        if (Input.GetButton("Fire1"))
        {
            Attak();
        }
        if(Input.GetKeyUp(miningKey))
        {
            MineMod(true);
            UIManager.Instance.MessageDown();
        }
        if(Input.GetKeyDown(reloadKey))
        {
            WeaponManager.Instance.StartCoroutine(WeaponManager.Instance.WeaponReloading());
        }

        ammoText.text = WeaponManager.Instance.weapon.ammoText;
    }

    private void SwapWeapon()
    {
        if(!WeaponManager.Instance.IsReloading)
        {
            float wheelInput = Input.GetAxis("Mouse ScrollWheel");
            if (wheelInput == 0) return;
            WeaponManager.Instance.SwapWeapon(wheelInput > 0);
        }
    }

    private void SearchItem()
    {
        Collider[] _item = Physics.OverlapSphere(transform.position, _itemFindRadius, _itemLayer);
        if (_item.Length > 0)
        {
            Dictionary<string, int> itemCheckList = new Dictionary<string, int>();
            Dictionary<string, DropItem> itemList = new Dictionary<string, DropItem>();
            foreach (var item in _item)
            {
                DropItem dropItem = item.transform.parent.GetComponent<DropItem>();
                if(itemCheckList.ContainsKey(dropItem.item.name))
                {
                    itemCheckList[dropItem.item.name]++;
                }
                else
                {
                    itemCheckList.Add(dropItem.item.name, 1);
                    itemList.Add(dropItem.item.name, dropItem);
                }
            }

            foreach(var item in itemCheckList)
            {
                ItemManager.Instance.GetItem(itemList[item.Key].gameObject, item.Value);
            }
        }
    }

    private void SearchOre()
    {
        RaycastHit hit;
        if(Physics.Raycast(transform.position, transform.forward + new Vector3(0, 0.5f, 0), out hit, _oreSearchRadius, _oreLayer))
        {
            if(!isMine && !_isFindOre)
            {
                UIManager.Instance.Message($"[ {miningKey} ] => Mine Mode Start");
                mineOre = hit.transform.GetComponent<Ore>();
                _isFindOre = true;
            }
        }
        else
        {
            if(isMine || _isFindOre)
            {
                UIManager.Instance.MessageDown();
                MineMod(false);
            }
        }
    }

    private void MineMod(bool value)
    {
        _isFindOre = false;
        _isMining = false;
        isMine = value;
    }

    private void Attak()
    {
        if(isMine)
        {
            if(_isMining == false)
            {
                playerMove.animator.SetTrigger("Mine");
                _isMining = true;
            }
            return;
        }

        if (attack.weapon == null) return;

        if (attack.weapon.bullet.ammo == 0) WeaponManager.Instance.StartCoroutine(WeaponManager.Instance.WeaponReloading());
        else if (!WeaponManager.Instance.IsReloading && !attack.AttackPossible)
        {
            attack.Attack();
        }
    }

    public void Mine()
    {
        _isMining = false;
        mineOre.TakeDamage(1);
        ItemManager.Instance.DropItem(mineOre.transform.position, mineOre.data.dropItem, mineOre.dropAmount);
    }


    public void TakeDamage(float damage)
    {
        _hp -= damage;
        UIManager.Instance.Popup(transform, damage.ToString(), true);

        if(_hp <= 0)
        {
            Debug.LogError("PLAYER DEATH");
        }
    }
}
