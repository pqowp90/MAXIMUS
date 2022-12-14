using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Player : MonoBehaviour
{
    public float hp;
    private bool _isOpenBag;
    public ItemDB inventory;

    [SerializeField]
    private LayerMask _itemLayer;
    [SerializeField]
    private float _itemFindRadius = 1f;

    private PlayerAttack attack;

    public TMP_Text ammoText;

    [Header("Keybinds")]
    public KeyCode reloadKey = KeyCode.R;
    public KeyCode bagOpenKey = KeyCode.E;

    private void Start()
    {
        attack = GetComponent<PlayerAttack>();
    }

    private void Update()
    {
        SearchItem();
        SwapWeapon();
        if (Input.GetButton("Fire1"))
        {
            Attak();
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
            foreach (var item in _item)
            {
                ItemManager.Instance.GetItem(item.GetComponentInParent<DropItem>().item);
                item.transform.parent.gameObject.SetActive(false);
            }
        }
    }

    private void Attak()
    {
        if (attack.weapon == null) return;

        if (attack.weapon.bullet.ammo == 0) WeaponManager.Instance.StartCoroutine(WeaponManager.Instance.WeaponReloading());
        else if (!WeaponManager.Instance.IsReloading && !attack.AttackPossible)
        {
            attack.Attack();
        }
    }
}
