import { reactive, provide, InjectionKey, ComponentInternalInstance } from "vue"

export type ParentProvide<T> = T & {
  link(child: ComponentInternalInstance): void
  unlink(child: ComponentInternalInstance): void
  children: ComponentInternalInstance[]
  internalChildren: ComponentInternalInstance[]
}

type ComponentInstance = ComponentInternalInstance & {
  provides: Record<string | symbol, unknown>
}

function getParent<T>(
  container: HTMLElement,
  key: InjectionKey<ParentProvide<T>>
) {
  let parentInstance: ComponentInstance | undefined
  let parent: any = container
  while ((parent = parent && parent.parentNode)) {
    if ("__instance" in parent) {
      const instance = parent.__instance as ComponentInstance
      if (instance && instance.provides) {
        const provides = instance.provides
        if (provides && (key as string | symbol) in provides) {
          parentInstance = instance
          break
        }
      }
    }
  }
  return parentInstance
}

function inject<T>(
  container: HTMLElement,
  key: InjectionKey<ParentProvide<T>>
) {
  const parent = getParent(container, key)
  if (parent) {
    return parent.provides[key as string | symbol] as ParentProvide<T>
  }
}

export function useParent<T>(
  instance: ComponentInternalInstance,
  key: InjectionKey<ParentProvide<T>>
) {
  const el = instance.vnode.el as HTMLElement
  const parent = inject(el, key)
  if (parent) {
    const { link } = parent
    link(instance)
    return parent
  }
}

export function useChildren<T>(key: InjectionKey<ParentProvide<T>>) {
  let publicChildren = reactive<ComponentInternalInstance[]>([])
  let internalChildren = reactive<ComponentInternalInstance[]>([])

  const linkChildren = (value?: any) => {
    const link = (child: ComponentInternalInstance) => {
      internalChildren.push(child)
      publicChildren.push(child)
    }

    const unlink = (child: ComponentInternalInstance) => {
      const index = internalChildren.indexOf(child)
      if (index > -1) {
        publicChildren.splice(index, 1)
        internalChildren.splice(index, 1)
      }
    }

    provide(
      key,
      Object.assign(
        {
          link,
          unlink,
          children: publicChildren,
          internalChildren
        },
        value
      )
    )
  }

  return {
    children: publicChildren,
    linkChildren
  }
}

function flattenChildren(
  children: HTMLCollection,
  key: InjectionKey<any> | string
) {
  const result: ComponentInternalInstance[] = []

  const traverse = (children: HTMLCollection) => {
    for (let i = 0; i < children.length; i++) {
      const child = children[i] as Element & {
        __instance: ComponentInternalInstance
      }
      if ("__instance" in child) {
        const instance = child.__instance
        if (instance) result.push(child.__instance)
      }
      if (child.children) {
        traverse(child.children)
      }
    }
  }

  traverse(children)

  return result
}
