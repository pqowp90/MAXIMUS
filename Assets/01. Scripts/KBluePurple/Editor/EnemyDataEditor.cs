// using System;
// using KBluePurple.Wave;
// using UnityEditor;
// using UnityEngine;
//
// namespace KBluePurple
// {
//     [CustomEditor(typeof(EnemyData))]
//     public class EnemyDataEditor : Editor
//     {
//         public override void OnInspectorGUI()
//         {
//             // base.OnInspectorGUI();
//             var enemyData = (EnemyData)target;
//             if (enemyData == null) return;
//
//             if (enemyData.sprite != null)
//             {
//                 try
//                 {
//                     EditorGUILayout.Space(10);
//                     var rect = GUILayoutUtility.GetRect(100, 100, 100, 100);
//                     rect.width = rect.height;
//                     rect.x = (EditorGUIUtility.currentViewWidth - rect.width + rect.x / 2) / 2;
//                     GUI.DrawTexture(rect, GetTexture(enemyData), ScaleMode.ScaleAndCrop);
//                     EditorGUILayout.Space(10);
//                 }
//                 catch
//                 {
//                     // ignored
//                 }
//             }
//
//             EditorGUILayout.BeginHorizontal();
//             GUILayout.FlexibleSpace();
//             enemyData.sprite =
//                 (Sprite)EditorGUILayout.ObjectField(enemyData.sprite, typeof(Sprite), false, GUILayout.Width(100));
//             GUILayout.FlexibleSpace();
//             EditorGUILayout.EndHorizontal();
//         }
//
//         private Texture2D GetTexture(EnemyData enemyData)
//         {
//             var texture = enemyData.sprite.texture;
//             var rect = enemyData.sprite.textureRect;
//             var pixels = texture.GetPixels((int)rect.x, (int)rect.y, (int)rect.width, (int)rect.height);
//             pixels = FlipPixels(pixels, (int)rect.width, (int)rect.height);
//             var result = new Texture2D((int)rect.width, (int)rect.height);
//             result.SetPixels(pixels);
//             return result;
//         }
//
//         private Color[] FlipPixels(Color[] pixels, int width, int height)
//         {
//             var result = new Color[pixels.Length];
//             for (var i = 0; i < pixels.Length; i++)
//             {
//                 var x = i % width;
//                 var y = i / width;
//                 result[i] = pixels[(height - y - 1) * width + x];
//             }
//
//             return result;
//         }
//     }
// }

