import { reactive, provide, InjectionKey, ComponentInternalInstance } from "@vue/runtime-core"
import { isNZothElement } from "../../dom/element"
import { extend } from "@vue/shared"

export type ParentProvide<T> = T & {
  link(child: ComponentInternalInstance): void
  unlink(child: ComponentInternalInstance): void
  children: ComponentInternalInstance[]
  internalChildren: ComponentInternalInstance[]
}

type ComponentInstance = ComponentInternalInstance & {
  provides: Record<string | symbol, unknown>
}

function getParent<T>(container: HTMLElement, key: InjectionKey<ParentProvide<T>>) {
  let parentInstance: ComponentInstance | undefined
  let parent: any = container
  while ((parent = parent && parent.parentNode)) {
    if (isNZothElement(parent)) {
      const instance = parent.__instance as ComponentInstance
      const provides = instance.provides
      if (provides) {
        if (provides && (key as string | symbol) in provides) {
          parentInstance = instance
          break
        }
      }
    }
  }
  return parentInstance
}

function inject<T>(container: HTMLElement, key: InjectionKey<ParentProvide<T>>) {
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
  const internalChildren = reactive<ComponentInternalInstance[]>([])

  const linkChildren = (value?: any) => {
    const link = (child: ComponentInternalInstance) => {
      internalChildren.push(child)
    }

    const unlink = (child: ComponentInternalInstance) => {
      const index = internalChildren.indexOf(child)
      if (index > -1) {
        internalChildren.splice(index, 1)
      }
    }

    provide(
      key,
      extend(
        {
          link,
          unlink,
          children: internalChildren
        },
        value
      )
    )
  }

  return {
    children: internalChildren,
    linkChildren
  }
}
